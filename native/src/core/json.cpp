#include "json.h"

#include <algorithm>
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
