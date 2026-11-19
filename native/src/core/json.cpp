#include "json.h"

#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <stdexcept>

namespace core {

class JsonParser {
 public:
  explicit JsonParser(const std::string& s) : s_(s) {}
  Json run() { Json v = value(); ws(); if (p_ != s_.size()) fail("fazla veri"); return v; }

 private:
  const std::string& s_;
  size_t p_ = 0;
  [[noreturn]] void fail(const char* what) { throw std::runtime_error(std::string("JSON hatası (") + what + ") konum " + std::to_string(p_)); }
  void ws() { while (p_ < s_.size() && (s_[p_] == ' ' || s_[p_] == '\n' || s_[p_] == '\r' || s_[p_] == '\t')) p_++; }
  bool lit(const char* w) { size_t n = std::char_traits<char>::length(w); if (s_.compare(p_, n, w) == 0) { p_ += n; return true; } return false; }
  static void utf8(std::string& o, uint32_t c) {
    if (c < 0x80) o += char(c);
    else if (c < 0x800) { o += char(0xC0 | (c >> 6)); o += char(0x80 | (c & 63)); }
    else if (c < 0x10000) { o += char(0xE0 | (c >> 12)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
    else { o += char(0xF0 | (c >> 18)); o += char(0x80 | ((c >> 12) & 63)); o += char(0x80 | ((c >> 6) & 63)); o += char(0x80 | (c & 63)); }
  }
  uint32_t hex4() {
    if (p_ + 4 > s_.size()) fail("kaçış");
    uint32_t v = 0;
    for (int k = 0; k < 4; k++) { char c = s_[p_++]; v <<= 4; if (c >= '0' && c <= '9') v |= c - '0'; else if (c >= 'a' && c <= 'f') v |= c - 'a' + 10; else if (c >= 'A' && c <= 'F') v |= c - 'A' + 10; else fail("kaçış"); }
    return v;
  }
  std::string string() {
    p_++;   // "
    std::string o;
    while (true) {
      if (p_ >= s_.size()) fail("bitmeyen metin");
      char c = s_[p_++];
      if (c == '"') return o;
      if (c != '\\') { o += c; continue; }
      if (p_ >= s_.size()) fail("kaçış");
      char e = s_[p_++];
      switch (e) {
        case '"': o += '"'; break; case '\\': o += '\\'; break; case '/': o += '/'; break;
        case 'b': o += '\b'; break; case 'f': o += '\f'; break; case 'n': o += '\n'; break; case 'r': o += '\r'; break; case 't': o += '\t'; break;
        case 'u': { uint32_t c1 = hex4();
          if (c1 >= 0xD800 && c1 < 0xDC00 && p_ + 1 < s_.size() && s_[p_] == '\\' && s_[p_ + 1] == 'u') { p_ += 2; uint32_t c2 = hex4(); c1 = 0x10000 + ((c1 - 0xD800) << 10) + (c2 - 0xDC00); }
          utf8(o, c1); } break;
        default: fail("kaçış");
      }
    }
  }
  Json value() {
    ws(); if (p_ >= s_.size()) fail("beklenmeyen son");
    Json v; char c = s_[p_];
    if (c == '{') {
      v.type_ = Json::Type::Object; v.index_ = std::make_shared<std::unordered_map<std::string, size_t>>(); p_++; ws();
      if (p_ < s_.size() && s_[p_] == '}') { p_++; return v; }
      while (true) {
        ws(); if (p_ >= s_.size() || s_[p_] != '"') fail("ad bekleniyor");
        std::string k = string(); ws(); if (p_ >= s_.size() || s_[p_] != ':') fail("':' bekleniyor"); p_++;
        (*v.index_)[k] = v.obj_.size(); v.obj_.emplace_back(std::move(k), value()); ws();
        if (p_ < s_.size() && s_[p_] == ',') { p_++; continue; }
        if (p_ < s_.size() && s_[p_] == '}') { p_++; return v; }
        fail("',' ya da '}' bekleniyor");
      }
    }
    if (c == '[') {
      v.type_ = Json::Type::Array; p_++; ws();
      if (p_ < s_.size() && s_[p_] == ']') { p_++; return v; }
      while (true) {
        v.arr_.push_back(value()); ws();
        if (p_ < s_.size() && s_[p_] == ',') { p_++; continue; }
        if (p_ < s_.size() && s_[p_] == ']') { p_++; return v; }
        fail("',' ya da ']' bekleniyor");
      }
    }
    if (c == '"') { v.type_ = Json::Type::String; v.str_ = string(); return v; }
    if (lit("true")) { v.type_ = Json::Type::Bool; v.bool_ = true; return v; }
    if (lit("false")) { v.type_ = Json::Type::Bool; return v; }
    if (lit("null")) return v;
    const char* st = s_.c_str() + p_; char* end = nullptr; double d = std::strtod(st, &end);
    if (end == st) fail("değer bekleniyor");
    p_ += size_t(end - st); v.type_ = Json::Type::Number; v.num_ = d; return v;
  }
};

Json Json::parse(const std::string& text) { return JsonParser(text).run(); }

const Json& Json::operator[](const std::string& key) const {
  if (type_ != Type::Object || !index_) return null();
  auto it = index_->find(key); return it == index_->end() ? null() : obj_[it->second].second;
}
Json* Json::mut(const std::string& key) {
  if (type_ != Type::Object || !index_) return nullptr;
  auto it = index_->find(key); return it == index_->end() ? nullptr : &obj_[it->second].second;
}
void Json::set(const std::string& key, Json v) {
  if (type_ != Type::Object) return;
  if (Json* p = mut(key)) { *p = std::move(v); return; }
  index_ = std::make_shared<std::unordered_map<std::string, size_t>>(index_ ? *index_ : std::unordered_map<std::string, size_t>());   // paylaşılan dizini ayır
  (*index_)[key] = obj_.size(); obj_.emplace_back(key, std::move(v));
}
void Json::erase(const std::string& key) {
  if (!has(key)) return;
  std::vector<std::pair<std::string, Json>> keep; for (auto& kv : obj_) if (kv.first != key) keep.push_back(std::move(kv));
  obj_ = std::move(keep); index_ = std::make_shared<std::unordered_map<std::string, size_t>>();
  for (size_t k = 0; k < obj_.size(); k++) (*index_)[obj_[k].first] = k;
}

// JS Number#toString (JSON.stringify): en kısa geri okunabilir rakamlar; üs 21 ve üstünde ya da −7 ve altında üslü yazım
std::string jsNumStr(double v) {
  if (!(v == v)) return "NaN";
  if (v - v != 0) return v > 0 ? "Infinity" : "-Infinity";
  if (v == 0) return "0";
  char b[48]; int p = 1;
  for (; p <= 17; p++) { std::snprintf(b, sizeof b, "%.*e", p - 1, v); if (std::strtod(b, nullptr) == v) break; }
  std::string t = b, sign; if (t[0] == '-') { sign = "-"; t = t.substr(1); }
  const size_t e = t.find('e'); std::string d; for (size_t k = 0; k < e; k++) if (t[k] != '.') d += t[k];
  while (d.size() > 1 && d.back() == '0') d.pop_back();
  const int n = std::atoi(t.c_str() + e + 1) + 1, k = int(d.size());
  std::string o;
  if (k <= n && n <= 21) o = d + std::string(size_t(n - k), '0');
  else if (0 < n && n <= 21) o = d.substr(0, size_t(n)) + "." + d.substr(size_t(n));
  else if (-6 < n && n <= 0) o = "0." + std::string(size_t(-n), '0') + d;
  else o = d.substr(0, 1) + (k > 1 ? "." + d.substr(1) : std::string()) + "e" + (n - 1 >= 0 ? "+" : "-") + std::to_string(std::abs(n - 1));
  return sign + o;
}
static void dumpNum(std::string& o, double v) {
  if (!(v == v) || v - v != 0) { o += "null"; return; }
  o += jsNumStr(v);
}
static void dumpStr(std::string& o, const std::string& s) {
  o += '"';
  for (unsigned char c : s) {
    if (c == '"') o += "\\\""; else if (c == '\\') o += "\\\\";
    else if (c == '\b') o += "\\b"; else if (c == '\f') o += "\\f"; else if (c == '\n') o += "\\n"; else if (c == '\r') o += "\\r"; else if (c == '\t') o += "\\t";
    else if (c < 0x20) { char b[8]; std::snprintf(b, sizeof b, "\\u%04x", c); o += b; }
    else o += char(c);
  }
  o += '"';
}
static void dumpTo(std::string& o, const Json& j) {
  switch (j.type()) {
    case Json::Type::Null: o += "null"; break;
    case Json::Type::Bool: o += j.b() ? "true" : "false"; break;
    case Json::Type::Number: dumpNum(o, j.num()); break;
    case Json::Type::String: dumpStr(o, j.str()); break;
    case Json::Type::Array: { o += '['; bool f = true; for (const Json& x : j.arr()) { if (!f) o += ','; f = false; dumpTo(o, x); } o += ']'; break; }
    case Json::Type::Object: { o += '{'; bool f = true; for (auto* kv : jsOrder(j)) { if (!f) o += ','; f = false; dumpStr(o, kv->first); o += ':'; dumpTo(o, kv->second); } o += '}'; break; }
  }
}
std::string Json::dump() const { std::string o; dumpTo(o, *this); return o; }

bool Json::has(const std::string& key) const { return type_ == Type::Object && index_ && index_->count(key); }

bool jsIntKey(const std::string& k) {
  if (k.empty() || k.size() >= 10) return false;
  for (char c : k) if (c < '0' || c > '9') return false;
  return k == "0" || k[0] != '0';
}
std::vector<const std::pair<std::string, Json>*> jsOrder(const Json& o) {
  std::vector<const std::pair<std::string, Json>*> num, rest;
  for (const auto& kv : o.obj()) (jsIntKey(kv.first) ? num : rest).push_back(&kv);
  std::stable_sort(num.begin(), num.end(), [](auto* a, auto* b) { return std::stoll(a->first) < std::stoll(b->first); });
  num.insert(num.end(), rest.begin(), rest.end());
  return num;
}

}  // namespace core
