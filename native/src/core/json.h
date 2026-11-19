// Küçük JSON okuyucu/yazıcı (oyunun veri dosyaları: data.json, ani.json, haritalar …; kayıt dosyası). Yazma: dump() = JS JSON.stringify
// (JS anahtar sırası, sayı en kısa geri okunabilir biçimde; NaN/sonsuz null).
// Kullanım: core::Json v = core::Json::parse(metin); v["reg"]["特效-刀光"][0].str(); v["w"].num();
#pragma once
#include <cstdint>
#include <memory>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace core {

class Json {
 public:
  enum class Type { Null, Bool, Number, String, Array, Object };
  static Json parse(const std::string& text);   // hata: std::runtime_error (konumuyla)

  Type type() const { return type_; }
  bool isNull() const { return type_ == Type::Null; }
  bool isNum() const { return type_ == Type::Number; }
  bool isStr() const { return type_ == Type::String; }
  bool isArr() const { return type_ == Type::Array; }
  bool isObj() const { return type_ == Type::Object; }

  double num(double def = 0) const { return type_ == Type::Number ? num_ : def; }
  int i(int def = 0) const { return type_ == Type::Number ? int(num_) : def; }
  bool b(bool def = false) const { return type_ == Type::Bool ? bool_ : def; }
  // JS doğruluğu (if (x)): null, false, 0, NaN ve "" yanlış; dizi ve nesne (boş da olsa) doğru
  bool truthy() const { return type_ == Type::Bool ? bool_ : type_ == Type::Number ? (num_ != 0 && num_ == num_) : type_ == Type::String ? !str_.empty() : type_ != Type::Null; }
  const std::string& str() const { static const std::string e; return type_ == Type::String ? str_ : e; }

  size_t size() const { return type_ == Type::Array ? arr_.size() : type_ == Type::Object ? obj_.size() : 0; }
  const Json& operator[](size_t k) const { return k < arr_.size() ? arr_[k] : null(); }
  const Json& operator[](int k) const { return k >= 0 ? (*this)[size_t(k)] : null(); }
  const Json& operator[](const std::string& key) const;   // yoksa null
  const Json& operator[](const char* key) const { return (*this)[std::string(key)]; }
  bool has(const std::string& key) const;
  const std::vector<Json>& arr() const { return arr_; }
  const std::vector<std::pair<std::string, Json>>& obj() const { return obj_; }   // ekleme sırasıyla

  static const Json& null() { static const Json n; return n; }
  // yazma (yükleme sonrası küçük düzeltmeler için): nesnedeki değer (yoksa nullptr); nesneye yaz (varsa yerine, yoksa sona)
  Json* mut(const std::string& key);
  void set(const std::string& key, Json v);
  static Json number(double v) { Json j; j.type_ = Type::Number; j.num_ = v; return j; }
  static Json array(std::vector<Json> a = {}) { Json j; j.type_ = Type::Array; j.arr_ = std::move(a); return j; }
  static Json text(std::string s) { Json j; j.type_ = Type::String; j.str_ = std::move(s); return j; }
  static Json boolean(bool b) { Json j; j.type_ = Type::Bool; j.bool_ = b; return j; }
  static Json object() { Json j; j.type_ = Type::Object; return j; }
  void push(Json v) { if (type_ == Type::Array) arr_.push_back(std::move(v)); }   // diziye ekle
  void erase(const std::string& key);                                              // nesneden sil (JS delete)
  std::string dump() const;                                                        // JSON.stringify

 private:
  friend class JsonParser;
  Type type_ = Type::Null;
  bool bool_ = false;
  double num_ = 0;
  std::string str_;
  std::vector<Json> arr_;
  std::vector<std::pair<std::string, Json>> obj_;
  std::shared_ptr<std::unordered_map<std::string, size_t>> index_;   // nesnede ad → sıra
};

// JS nesnesinin anahtar sırası (Object.keys / for…in / Object.entries): tam sayı biçimli anahtarlar önce (artan), sonra ötekiler ekleme sırasıyla
std::vector<const std::pair<std::string, Json>*> jsOrder(const Json& o);
bool jsIntKey(const std::string& k);
// JS String(sayı) / Number#toString: 30 → "30", 0.1 → "0.1", 1e21 → "1e+21"
std::string jsNumStr(double v);

}  // namespace core
