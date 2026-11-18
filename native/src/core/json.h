// Küçük JSON okuyucu (oyunun veri dosyaları için: data.json, ani.json, haritalar …). Yazma yok.
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

}  // namespace core
