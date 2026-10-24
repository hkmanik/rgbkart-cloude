// Bangladesh mobile numbers in one format (24 Oct 2026). People type 01711000000, +8801711000000, 8801711000000,
// "017 1100 0000" or 1711000000; RGBKart stores and checks 01XXXXXXXXX (what the database rules accept).
//   RGBPhone.clean(text) → '01711000000' when it is a Bangladesh mobile number, else the text without spaces/dashes
//   RGBPhone.ok(text)    → true for a valid Bangladesh mobile number in any of those forms
(function () {
  function clean(s) {
    var t = String(s == null ? '' : s).trim();
    var d = t.replace(/\D/g, '');
    if (/^8801[3-9]\d{8}$/.test(d)) return '0' + d.slice(3);
    if (/^01[3-9]\d{8}$/.test(d)) return d;
    if (/^1[3-9]\d{8}$/.test(d)) return '0' + d;
    return t.replace(/[\s\-().]/g, '');
  }
  function ok(s) { return /^01[3-9]\d{8}$/.test(clean(s)); }
  window.RGBPhone = { clean: clean, ok: ok };
})();
