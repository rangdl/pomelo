// 咪咕音乐 —— 上游 Domdkw/MusicFree-migu（dist/migu-plugin.js，platform=咪咕）。
// pomelo 适配：仅依赖 axios（由运行时 musicfree_compat 翻译成 fetch 垫片），
// 无 crypto-js / cheerio 依赖；接口统一使用 app.c.nf.migu.cn 新版 bmw/MIGUM3.0，
// 原上游少量 http:// 已改为 https://（避免明文被系统拦截）。
function _regenerator() { /*! regenerator-runtime -- Copyright (c) 2014-present, Facebook, Inc. -- license (MIT): https://github.com/babel/babel/blob/main/packages/babel-helpers/LICENSE */ var e, t, r = "function" == typeof Symbol ? Symbol : {}, n = r.iterator || "@@iterator", o = r.toStringTag || "@@toStringTag"; function i(r, n, o, i) { var c = n && n.prototype instanceof Generator ? n : Generator, u = Object.create(c.prototype); return _regeneratorDefine2(u, "_invoke", function (r, n, o) { var i, c, u, f = 0, p = o || [], y = !1, G = { p: 0, n: 0, v: e, a: d, f: d.bind(e, 4), d: function d(t, r) { return i = t, c = 0, u = e, G.n = r, a; } }; function d(r, n) { for (c = r, u = n, t = 0; !y && f && !o && t < p.length; t++) { var o, i = p[t], d = G.p, l = i[2]; r > 3 ? (o = l === n) && (u = i[(c = i[4]) ? 5 : (c = 3, 3)], i[4] = i[5] = e) : i[0] <= d && ((o = r < 2 && d < i[1]) ? (c = 0, G.v = n, G.n = i[1]) : d < l && (o = r < 3 || i[0] > n || n > l) && (i[4] = r, i[5] = n, G.n = l, c = 0)); } if (o || r > 1) return a; throw y = !0, n; } return function (o, p, l) { if (f > 1) throw TypeError("Generator is already running"); for (y && 1 === p && d(p, l), c = p, u = l; (t = c < 2 ? e : u) || !y;) { i || (c ? c < 3 ? (c > 1 && (G.n = -1), d(c, u)) : G.n = u : G.v = u); try { if (f = 2, i) { if (c || (o = "next"), t = i[o]) { if (!(t = t.call(i, u))) throw TypeError("iterator result is not an object"); if (!t.done) return t; u = t.value, c < 2 && (c = 0); } else 1 === c && (t = i.return) && t.call(i), c < 2 && (u = TypeError("The iterator does not provide a '" + o + "' method"), c = 1); i = e; } else if ((t = (y = G.n < 0) ? u : r.call(n, G)) !== a) break; } catch (t) { i = e, c = 1, u = t; } finally { f = 1; } } return { value: t, done: y }; }; }(r, o, i), !0), u; } var a = {}; function Generator() {} function GeneratorFunction() {} function GeneratorFunctionPrototype() {} t = Object.getPrototypeOf; var c = [][n] ? t(t([][n]())) : (_regeneratorDefine2(t = {}, n, function () { return this; }), t), u = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(c); function f(e) { return Object.setPrototypeOf ? Object.setPrototypeOf(e, GeneratorFunctionPrototype) : (e.__proto__ = GeneratorFunctionPrototype, _regeneratorDefine2(e, o, "GeneratorFunction")), e.prototype = Object.create(u), e; } return GeneratorFunction.prototype = GeneratorFunctionPrototype, _regeneratorDefine2(u, "constructor", GeneratorFunctionPrototype), _regeneratorDefine2(GeneratorFunctionPrototype, "constructor", GeneratorFunction), GeneratorFunction.displayName = "GeneratorFunction", _regeneratorDefine2(GeneratorFunctionPrototype, o, "GeneratorFunction"), _regeneratorDefine2(u), _regeneratorDefine2(u, o, "Generator"), _regeneratorDefine2(u, n, function () { return this; }), _regeneratorDefine2(u, "toString", function () { return "[object Generator]"; }), (_regenerator = function _regenerator() { return { w: i, m: f }; })(); }
function _regeneratorDefine2(e, r, n, t) { var i = Object.defineProperty; try { i({}, "", {}); } catch (e) { i = 0; } _regeneratorDefine2 = function _regeneratorDefine(e, r, n, t) { function o(r, n) { _regeneratorDefine2(e, r, function (e) { return this._invoke(r, n, e); }); } r ? i ? i(e, r, { value: n, enumerable: !t, configurable: !t, writable: !t }) : e[r] = n : (o("next", 0), o("throw", 1), o("return", 2)); }, _regeneratorDefine2(e, r, n, t); }
function _slicedToArray(r, e) { return _arrayWithHoles(r) || _iterableToArrayLimit(r, e) || _unsupportedIterableToArray(r, e) || _nonIterableRest(); }
function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _iterableToArrayLimit(r, l) { var t = null == r ? null : "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (null != t) { var e, n, i, u, a = [], f = !0, o = !1; try { if (i = (t = t.call(r)).next, 0 === l) { if (Object(t) !== t) return; f = !1; } else for (; !(f = (e = i.call(t)).done) && (a.push(e.value), a.length !== l); f = !0); } catch (r) { o = !0, n = r; } finally { try { if (!f && null != t.return && (u = t.return(), Object(u) !== u)) return; } finally { if (o) throw n; } } return a; } }
function _arrayWithHoles(r) { if (Array.isArray(r)) return r; }
function asyncGeneratorStep(n, t, e, r, o, a, c) { try { var i = n[a](c), u = i.value; } catch (n) { return void e(n); } i.done ? t(u) : Promise.resolve(u).then(r, o); }
function _asyncToGenerator(n) { return function () { var t = this, e = arguments; return new Promise(function (r, o) { var a = n.apply(t, e); function _next(n) { asyncGeneratorStep(a, r, o, _next, _throw, "next", n); } function _throw(n) { asyncGeneratorStep(a, r, o, _next, _throw, "throw", n); } _next(void 0); }); }; }
function _createForOfIteratorHelper(r, e) { var t = "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (!t) { if (Array.isArray(r) || (t = _unsupportedIterableToArray(r)) || e && r && "number" == typeof r.length) { t && (r = t); var _n = 0, F = function F() {}; return { s: F, n: function n() { return _n >= r.length ? { done: !0 } : { done: !1, value: r[_n++] }; }, e: function e(r) { throw r; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var o, a = !0, u = !1; return { s: function s() { t = t.call(r); }, n: function n() { var r = t.next(); return a = r.done, r; }, e: function e(r) { u = !0, o = r; }, f: function f() { try { a || null == t.return || t.return(); } finally { if (u) throw o; } } }; }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
var Z = Object.create;
var w = Object.defineProperty;
var q = Object.getOwnPropertyDescriptor;
var H = Object.getOwnPropertyNames;
var z = Object.getPrototypeOf,
  B = Object.prototype.hasOwnProperty;
var F = function F(t, n, e, r) {
  if (n && _typeof(n) == "object" || typeof n == "function") {
    var _iterator = _createForOfIteratorHelper(H(n)),
      _step;
    try {
      var _loop = function _loop() {
        var a = _step.value;
        !B.call(t, a) && a !== e && w(t, a, {
          get: function get() {
            return n[a];
          },
          enumerable: !(r = q(n, a)) || r.enumerable
        });
      };
      for (_iterator.s(); !(_step = _iterator.n()).done;) {
        _loop();
      }
    } catch (err) {
      _iterator.e(err);
    } finally {
      _iterator.f();
    }
  }
  return t;
};
var f = function f(t, n, e) {
  return e = t != null ? Z(z(t)) : {}, F(n || !t || !t.__esModule ? w(e, "default", {
    value: t,
    enumerable: !0
  }) : e, t);
};
var p = f(require("axios"));
var N = f(require("axios")),
  G = /*#__PURE__*/function () {
    var _ref = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee(t, n) {
      var e, r, a, s;
      return _regenerator().w(function (_context) {
        while (1) switch (_context.n) {
          case 0:
            e = ((n == null ? void 0 : n.method) || "GET").toUpperCase(), r = n == null ? void 0 : n.headers, a = {};
            r && (r instanceof Headers ? r.forEach(function (o, i) {
              a[i] = o;
            }) : Array.isArray(r) ? r.forEach(function (_ref2) {
              var _ref3 = _slicedToArray(_ref2, 2),
                o = _ref3[0],
                i = _ref3[1];
              a[o] = i;
            }) : a = r);
            s = {
              url: t,
              method: e,
              headers: a,
              params: n == null ? void 0 : n.params,
              maxRedirects: n == null ? void 0 : n.maxRedirects,
              data: n == null ? void 0 : n.body
            };
            n != null && n.signal && (s.signal = n.signal);
            _context.n = 1;
            return (0, N.default)(s);
          case 1:
            return _context.a(2, _context.v);
        }
      }, _callee);
    }));
    return function G(_x, _x2) {
      return _ref.apply(this, arguments);
    };
  }(),
  m = /*#__PURE__*/function () {
    var _ref4 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee2(t, n) {
      return _regenerator().w(function (_context2) {
        while (1) switch (_context2.n) {
          case 0:
            _context2.n = 1;
            return G(t, n);
          case 1:
            return _context2.a(2, _context2.v.data);
        }
      }, _callee2);
    }));
    return function m(_x3, _x4) {
      return _ref4.apply(this, arguments);
    };
  }();
var x = /*#__PURE__*/function () {
  var _ref5 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee3(t) {
    var n,
      e,
      r,
      _args3 = arguments;
    return _regenerator().w(function (_context3) {
      while (1) switch (_context3.n) {
        case 0:
          n = _args3.length > 1 && _args3[1] !== undefined ? _args3[1] : 2;
          e = _args3.length > 2 && _args3[2] !== undefined ? _args3[2] : 20;
          r = _args3.length > 3 && _args3[3] !== undefined ? _args3[3] : 0;
          _context3.n = 1;
          return m("https://u.musicapp.migu.cn/MIGUM3.0/user/comment/stack/v1.0?resourceId=".concat(t, "&resourceType=").concat(n, "&pageSize=").concat(e, "&hotCommentStart=").concat(r, "&platformType=1&commentId=0&queryType=1"));
        case 1:
          return _context3.a(2, _context3.v);
      }
    }, _callee3);
  }));
  return function x(_x5) {
    return _ref5.apply(this, arguments);
  };
}();
var L = /*#__PURE__*/function () {
  var _ref6 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee4(t) {
    var n,
      e,
      _args4 = arguments;
    return _regenerator().w(function (_context4) {
      while (1) switch (_context4.n) {
        case 0:
          n = _args4.length > 1 && _args4[1] !== undefined ? _args4[1] : 1;
          e = _args4.length > 2 && _args4[2] !== undefined ? _args4[2] : 0;
          _context4.n = 1;
          return m("https://app.c.nf.migu.cn/bmw/search/music-list/v1.0?pageNo=".concat(n, "&text=").concat(t, "&typeOrder=").concat(e));
        case 1:
          return _context4.a(2, _context4.v);
      }
    }, _callee4);
  }));
  return function L(_x6) {
    return _ref6.apply(this, arguments);
  };
}();
var y = f(require("axios")),
  S = /*#__PURE__*/function () {
    var _ref7 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee5(t) {
      var n, e, r, a, s;
      return _regenerator().w(function (_context5) {
        while (1) switch (_context5.n) {
          case 0:
            if (!(t === "")) {
              _context5.n = 1;
              break;
            }
            return _context5.a(2, {
              error: "contentId is empty!",
              success: !1
            });
          case 1:
            _context5.n = 2;
            return y.default.get("https://app.c.nf.migu.cn/resource/song/by-contentids/v2.0?contentId=".concat(t));
          case 2:
            n = _context5.v;
            e = n.data.code.toString() || "";
            r = n.data.data || [];
            if (!(e !== "000000")) {
              _context5.n = 3;
              break;
            }
            return _context5.a(2, {
              success: !1,
              status: n.status,
              error: n.data.info || n.data
            });
          case 3:
            if (!(r.length === 0)) {
              _context5.n = 4;
              break;
            }
            return _context5.a(2, {
              error: "data.length = 0 !",
              success: !1,
              data: r
            });
          case 4:
            a = r[0].lrcUrl || "";
            if (!(a === "")) {
              _context5.n = 5;
              break;
            }
            return _context5.a(2, {
              error: "lrcUrl is empty!",
              success: !1,
              data: r
            });
          case 5:
            _context5.n = 6;
            return y.default.get(a);
          case 6:
            s = _context5.v;
            return _context5.a(2, s.status !== 200 ? {
              success: !1,
              status: s.status,
              error: "lrcRes.status !== 200 !",
              data: r
            } : {
              success: !0,
              lrc: s.data || "",
              lrcUrl: a
            });
        }
      }, _callee5);
    }));
    return function S(_x7) {
      return _ref7.apply(this, arguments);
    };
  }();
var v = /*#__PURE__*/function () {
  var _ref8 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee6(t) {
    return _regenerator().w(function (_context6) {
      while (1) switch (_context6.n) {
        case 0:
          t = encodeURIComponent(t);
          _context6.n = 1;
          return m("http://c.musicapp.migu.cn/v1.0/content/get-import-songList?url=".concat(t));
        case 1:
          return _context6.a(2, _context6.v);
      }
    }, _callee6);
  }));
  return function v(_x8) {
    return _ref8.apply(this, arguments);
  };
}();
var R = f(require("axios"));
var J = ["LQ", "PQ", "HQ", "SQ", "ZQ24", "ZQ32", "Z3D", "3D60"],
  g = encodeURI,
  b = {
    LQ: g("\u5168\u66F2\u8BD5\u542C/Mp3_64_22_16"),
    PQ: g("\u6807\u6E05\u9AD8\u6E05/MP3_128_16_Stero"),
    HQ: g("\u6807\u6E05\u9AD8\u6E05/MP3_320_16_Stero"),
    SQ: g("\u6B4C\u66F2\u4E0B\u8F7D/flac"),
    ZQ24: g("\u6B4C\u66F2\u4E0B\u8F7D/flac_24bit"),
    ZQ32: g("\u6B4C\u66F2\u4E0B\u8F7D/wav_32bit"),
    Z3D: g("\u6B4C\u66F2\u4E0B\u8F7D/wav_3d"),
    "3D60": g("\u6B4C\u66F2\u4E0B\u8F7D/wav_3d_60s")
  },
  T = Object.entries(b),
  U = {
    LQ: ".mp3",
    PQ: ".mp3",
    HQ: ".mp3",
    SQ: ".flac",
    ZQ24: ".flac",
    ZQ32: ".wav",
    Z3D: ".wav",
    "3D60": ".wav"
  };
function h(t) {
  return J.includes(t);
}
function O(t) {
  var n = "";
  if (!n) for (var e = 0; e < T.length; e++) {
    var _T$e = _slicedToArray(T[e], 2),
      r = _T$e[0],
      a = _T$e[1];
    if (t.includes(a)) {
      n = r;
      break;
    }
  }
  return n;
}
function k(t, n, e) {
  var r = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : !0;
  var a = h(e) ? e : O(t);
  return r && (t = t.split("?")[0]), !h(n) || !h(a) ? t : t.replace(b[a], b[n]).replace(U[a], U[n]);
}
var C = /*#__PURE__*/function () {
    var _ref9 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee7(t, n) {
      var e,
        o,
        r,
        a,
        s,
        _args7 = arguments;
      return _regenerator().w(function (_context7) {
        while (1) switch (_context7.n) {
          case 0:
            e = _args7.length > 2 && _args7[2] !== undefined ? _args7[2] : "PQ";
            r = {
              birth: "h5page",
              channel: "014X031",
              Referer: "https://y.migu.cn/",
              "location-data": "30.6698676660,104.1229614820",
              "location-info": ""
            };
            _context7.n = 1;
            return R.default.get("https://c.musicapp.migu.cn/strategy/listen-url/h5/v2.4?contentId=".concat(t, "&copyrightId=").concat(n, "&resourceType=2&netType=01&toneFlag=PQ&scene=&lowerQualityContentId=").concat(t), {
              headers: r,
              responseType: "arraybuffer"
            });
          case 1:
            a = _context7.v;
            _context7.n = 2;
            return Y(a.data);
          case 2:
            s = _context7.v;
            return _context7.a(2, ((o = s == null ? void 0 : s.data) == null ? void 0 : o.url) === "" ? {
              success: !1,
              error: "URL \u4E3A\u7A7A"
            } : (s.data.oriUrl = s.data.url || "", s.data.url = k(s.data.url || "", e, "PQ", !0), s));
        }
      }, _callee7);
    }));
    return function C(_x9, _x0) {
      return _ref9.apply(this, arguments);
    };
  }(),
  V = ["Jk8qzuePiJ1qE3mDYhLQ3T73DtDoAhLP"];
function W(t) {
  return new TextEncoder().encode(t);
}
function K(t) {
  var n = [];
  var _iterator2 = _createForOfIteratorHelper(t),
    _step2;
  try {
    for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
      var e = _step2.value;
      e < 16 ? n.push(String.fromCharCode(e)) : (n.push("%"), n.push(e.toString(16)));
    }
  } catch (err) {
    _iterator2.e(err);
  } finally {
    _iterator2.f();
  }
  return decodeURIComponent(n.join(""));
}
function X(t, n) {
  if (n.length == 0) return null;
  var e = t.length;
  if (e < 4 || t[0] != 171 || t[1] != 205 || t[2] != 1) return null;
  for (var r = t[3], a = W(n), s = a.length, o = new Uint8Array(e - 4), i = 0, c = 4; c < e; c++, i++) o[i] = t[c] + r - a[i % s];
  return o;
}
var Y = function Y(t) {
  var n = X(new Uint8Array(t), V[0]),
    e = K(n);
  return JSON.parse(e);
};
var Q = /*#__PURE__*/function () {
  var _ref0 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee8() {
    return _regenerator().w(function (_context8) {
      while (1) switch (_context8.n) {
        case 0:
          _context8.n = 1;
          return m("https://app.u.nf.migu.cn/bmw/rank/rank-index/v2.0");
        case 1:
          return _context8.a(2, _context8.v);
      }
    }, _callee8);
  }));
  return function Q() {
    return _ref0.apply(this, arguments);
  };
}();
var $ = /*#__PURE__*/function () {
  var _ref1 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee9(t) {
    var n,
      _args9 = arguments;
    return _regenerator().w(function (_context9) {
      while (1) switch (_context9.n) {
        case 0:
          n = _args9.length > 1 && _args9[1] !== undefined ? _args9[1] : 1;
          _context9.n = 1;
          return m("https://app.c.nf.migu.cn/bmw/rank/rank-info/v1.0?pageNo=".concat(n, "&rankId=").concat(t));
        case 1:
          return _context9.a(2, _context9.v);
      }
    }, _callee9);
  }));
  return function $(_x1) {
    return _ref1.apply(this, arguments);
  };
}();
var D = /*#__PURE__*/function () {
  var _ref10 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee0(t) {
    var n,
      e,
      _args0 = arguments;
    return _regenerator().w(function (_context0) {
      while (1) switch (_context0.n) {
        case 0:
          n = _args0.length > 1 && _args0[1] !== undefined ? _args0[1] : 1;
          e = _args0.length > 2 && _args0[2] !== undefined ? _args0[2] : 20;
          _context0.n = 1;
          return m("https://app.c.nf.migu.cn/MIGUM3.0/resource/playlist/song/v2.0?pageNo=".concat(n, "&pageSize=").concat(e, "&playlistId=").concat(t));
        case 1:
          return _context0.a(2, _context0.v);
      }
    }, _callee0);
  }));
  return function D(_x10) {
    return _ref10.apply(this, arguments);
  };
}();
var E = /*#__PURE__*/function () {
  var _ref11 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee1(t) {
    var n,
      _args1 = arguments;
    return _regenerator().w(function (_context1) {
      while (1) switch (_context1.n) {
        case 0:
          n = _args1.length > 1 && _args1[1] !== undefined ? _args1[1] : 1;
          _context1.n = 1;
          return m("https://app.c.nf.migu.cn/bmw/search/lrc/v1.0?pageNo=".concat(n, "&text=").concat(t));
        case 1:
          return _context1.a(2, _context1.v);
      }
    }, _callee1);
  }));
  return function E(_x11) {
    return _ref11.apply(this, arguments);
  };
}();
var I = /*#__PURE__*/function () {
  var _ref12 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee10() {
    var t,
      n,
      e,
      _args10 = arguments;
    return _regenerator().w(function (_context10) {
      while (1) switch (_context10.n) {
        case 0:
          t = _args10.length > 0 && _args10[0] !== undefined ? _args10[0] : !0;
          _context10.n = 1;
          return m("https://app.c.nf.migu.cn/pc/bmw/playlist-square/tab/v1.0");
        case 1:
          n = _context10.v;
          if (t) {
            _context10.n = 2;
            break;
          }
          return _context10.a(2, n);
        case 2:
          _context10.n = 3;
          return m("https://app.c.nf.migu.cn/pc/v1.0/template/musiclistplaza-taglist/release");
        case 3:
          e = _context10.v;
          return _context10.a(2, (n.data.moreTag = e.data.map(function (r) {
            var o;
            var a = (o = r == null ? void 0 : r.header) == null ? void 0 : o.title,
              s = r == null ? void 0 : r.content.map(function (i) {
                return {
                  tagName: i.texts[0],
                  tagId: i.texts[1]
                };
              });
            return {
              title: a,
              tagList: s
            };
          }), n));
      }
    }, _callee10);
  }));
  return function I() {
    return _ref12.apply(this, arguments);
  };
}();
var A = /*#__PURE__*/function () {
  var _ref13 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee11(t, n) {
    var r, a, s, o, i, e;
    return _regenerator().w(function (_context11) {
      while (1) switch (_context11.n) {
        case 0:
          _context11.n = 1;
          return m("https://app.c.nf.migu.cn/MIGUM3.0/v1.0/template/musiclistplaza-listbytag?templateVersion=1&tagId=".concat(t, "&pageNumber=").concat(n));
        case 1:
          e = _context11.v;
          return _context11.a(2, (e.data.contentItemList = ((s = (a = (r = e == null ? void 0 : e.data) == null ? void 0 : r.contentItemList) == null ? void 0 : a.itemList) == null ? void 0 : s.reduce(function (c, u) {
            return !u.actionUrl || !u.actionUrl.includes("song-list-info") || (u.playlistId = u.actionUrl.split("id=")[1].split("&")[0] || "", c.push(u)), c;
          }, [])) || [], e.data.hasNext = e.data.contentItemList.length < 30 ? !1 : ((o = e == null ? void 0 : e.data) == null ? void 0 : o.nextPageUrl) !== void 0 && ((i = e == null ? void 0 : e.data) == null ? void 0 : i.nextPageUrl) !== "", e));
      }
    }, _callee11);
  }));
  return function A(_x12, _x13) {
    return _ref13.apply(this, arguments);
  };
}();
var P = /*#__PURE__*/function () {
  var _ref14 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee12() {
    var t,
      _args12 = arguments;
    return _regenerator().w(function (_context12) {
      while (1) switch (_context12.n) {
        case 0:
          t = _args12.length > 0 && _args12[0] !== undefined ? _args12[0] : "";
          t = t.replace(/,/g, "|");
          _context12.n = 1;
          return m("https://app.c.nf.migu.cn/resource/song/by-contentids/v2.0?contentId=".concat(t));
        case 1:
          return _context12.a(2, _context12.v);
      }
    }, _callee12);
  }));
  return function P() {
    return _ref14.apply(this, arguments);
  };
}();
var M = /*#__PURE__*/function () {
  var _ref15 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee13(t) {
    var n,
      r,
      a,
      e,
      _args13 = arguments;
    return _regenerator().w(function (_context13) {
      while (1) switch (_context13.n) {
        case 0:
          n = _args13.length > 1 && _args13[1] !== undefined ? _args13[1] : 1;
          _context13.n = 1;
          return m("https://app.c.nf.migu.cn/bmw/singer/album/v1.0?singerId=".concat(t, "&pageNo=").concat(n));
        case 1:
          e = _context13.v;
          return _context13.a(2, ((a = (r = e == null ? void 0 : e.data) == null ? void 0 : r.header) != null && a.nextPageUrl ? e.data.header.hasNext = !0 : e.data.header.hasNext = !1, e));
      }
    }, _callee13);
  }));
  return function M(_x14) {
    return _ref15.apply(this, arguments);
  };
}();
var _ = /*#__PURE__*/function () {
  var _ref16 = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee14(t) {
    return _regenerator().w(function (_context14) {
      while (1) switch (_context14.n) {
        case 0:
          _context14.n = 1;
          return m("https://app.c.nf.migu.cn/MIGUM3.0/resource/dalbum/song/v2.0?dAlbumId=".concat(t));
        case 1:
          return _context14.a(2, _context14.v);
      }
    }, _callee14);
  }));
  return function _(_x15) {
    return _ref16.apply(this, arguments);
  };
}();
function tt(_x16, _x17) {
  return _tt.apply(this, arguments);
}
function _tt() {
  _tt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee18(t, n) {
    var r, a;
    return _regenerator().w(function (_context18) {
      while (1) switch (_context18.n) {
        case 0:
          _context18.n = 1;
          return p.default.get("https://app.c.nf.migu.cn/bmw/search/song/v1.0?pageNo=".concat(n, "&text=").concat(t));
        case 1:
          r = _context18.v.data.data;
          a = r.hasNext;
          return _context18.a(2, {
            data: r.items.map(function (i) {
              var c = i.song,
                u = c.singerList.map(function (d) {
                  return d.name;
                });
              return c.artistNames = u.join("/"), l(c);
            }),
            isEnd: !a
          });
      }
    }, _callee18);
  }));
  return _tt.apply(this, arguments);
}
function l(t) {
  return {
    id: t.contentId,
    title: t.songName,
    artist: t.artistNames,
    album: t.album,
    duration: t.duration,
    artwork: "https://d.musicapp.migu.cn" + t.img3,
    albumId: t.albumId,
    lrc: t.lrcUrl,
    singerList: t.singerList,
    resourceType: String(t.resourceType),
    mvId: t.mvId,
    ringToneId: t.ringToneId,
    ringCopyrightId: t.ringCopyrightId,
    copyrightId: t.copyrightId,
    playNumDesc: t.playNumDesc
  };
}
function nt(_x18, _x19) {
  return _nt.apply(this, arguments);
}
function _nt() {
  _nt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee19(t, n) {
    var e;
    return _regenerator().w(function (_context19) {
      while (1) switch (_context19.n) {
        case 0:
          _context19.n = 1;
          return L(t, n);
        case 1:
          e = _context19.v;
          return _context19.a(2, {
            data: e.data.items.map(function (a) {
              var s = a.musicList;
              return {
                id: s.musicListId,
                artist: s.ownerName,
                title: s.title,
                artwork: s.originalImgUrl
              };
            }),
            isEnd: !e.data.hasNext
          });
      }
    }, _callee19);
  }));
  return _nt.apply(this, arguments);
}
function et(_x20, _x21) {
  return _et.apply(this, arguments);
}
function _et() {
  _et = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee20(t, n) {
    var e;
    return _regenerator().w(function (_context20) {
      while (1) switch (_context20.n) {
        case 0:
          _context20.n = 1;
          return E(t, n);
        case 1:
          e = _context20.v;
          return _context20.a(2, {
            data: e.data.items.map(function (a) {
              var s = a.song,
                o = s.singerList.map(function (i) {
                  return i.name;
                });
              return s.artistNames = o.join("/"), l(s);
            }),
            isEnd: !e.data.hasNext
          });
      }
    }, _callee20);
  }));
  return _et.apply(this, arguments);
}
function at(_x22, _x23) {
  return _at.apply(this, arguments);
}
function _at() {
  _at = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee21(t, n) {
    var r, a;
    return _regenerator().w(function (_context21) {
      while (1) switch (_context21.n) {
        case 0:
          _context21.n = 1;
          return p.default.get("https://app.c.nf.migu.cn/bmw/search/album/v1.0?pageNo=".concat(n, "&text=").concat(t));
        case 1:
          r = _context21.v.data.data;
          a = r.hasNext;
          return _context21.a(2, {
            data: r.items.map(function (i) {
              var c = Object.keys(i)[0];
              if (c === "album") {
                var u = i.album;
                return rt(u);
              } else if (c === "dalbum") {
                var _u = i.dalbum;
                return {
                  id: _u.contentId,
                  title: _u.title,
                  artist: _u.singer,
                  artistId: _u.singerId,
                  artwork: _u.imgItems[0].img,
                  date: _u.publishDate,
                  resourceType: String(_u.resourceType),
                  totalCount: _u.totalCount
                };
              }
            }),
            isEnd: !a
          });
      }
    }, _callee21);
  }));
  return _at.apply(this, arguments);
}
function rt(t) {
  return {
    id: t.albumId,
    title: t.title,
    artist: t.singer,
    artistId: t.singerId,
    artwork: t.imgItems[0].img,
    date: t.publishDate,
    resourceType: String(t.resourceType),
    totalCount: t.totalCount
  };
}
function st(_x24, _x25) {
  return _st.apply(this, arguments);
}
function _st() {
  _st = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee22(t, n) {
    var r, a;
    return _regenerator().w(function (_context22) {
      while (1) switch (_context22.n) {
        case 0:
          _context22.n = 1;
          return p.default.get("https://app.c.nf.migu.cn/bmw/search/singer/v2.0?pageNo=".concat(n, "&text=").concat(t));
        case 1:
          r = _context22.v.data.data;
          a = r.hasNext;
          return _context22.a(2, {
            data: r.items.map(function (i) {
              var c = i.singer;
              return ot(c);
            }),
            isEnd: !a
          });
      }
    }, _callee22);
  }));
  return _st.apply(this, arguments);
}
function ot(t) {
  return {
    id: t.singerId,
    name: t.singer,
    fans: t.followNums,
    description: t.summary,
    avatar: t.imgs[0].img,
    worksNum: t.songNum,
    mvNum: t.mvNum,
    albumNum: t.albumNum,
    vrbtNum: t.vrbtNum,
    latestContentId: t.latestContentId,
    columnId: t.columnId,
    videoUserId: t.videoUserId,
    resourceType: t.resourceType
  };
}
function it(_x26, _x27) {
  return _it.apply(this, arguments);
}
function _it() {
  _it = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee23(t, n) {
    var e, r, a, _t8;
    return _regenerator().w(function (_context23) {
      while (1) switch (_context23.n) {
        case 0:
          e = "";
          _t8 = n;
          _context23.n = _t8 === "standard" ? 1 : _t8 === "low" ? 1 : _t8 === "high" ? 2 : _t8 === "super" ? 3 : 4;
          break;
        case 1:
          e = "PQ";
          return _context23.a(3, 5);
        case 2:
          e = "HQ";
          return _context23.a(3, 5);
        case 3:
          e = "SQ";
          return _context23.a(3, 5);
        case 4:
          e = "PQ";
          return _context23.a(3, 5);
        case 5:
          _context23.n = 6;
          return C(t.id, t.copyrightId || "", e);
        case 6:
          r = _context23.v;
          a = (r == null ? void 0 : r.data) || {};
          return _context23.a(2, {
            url: (a == null ? void 0 : a.url) || ""
          });
      }
    }, _callee23);
  }));
  return _it.apply(this, arguments);
}
function ct(_x28, _x29) {
  return _ct.apply(this, arguments);
}
function _ct() {
  _ct = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee24(t, n) {
    var s, e;
    return _regenerator().w(function (_context24) {
      while (1) switch (_context24.n) {
        case 0:
          _context24.n = 1;
          return p.default.get("https://app.c.nf.migu.cn/MIGUM3.0/resource/album/song/v2.0?albumId=".concat(t.id, "&pageNo=").concat(n || 1));
        case 1:
          e = _context24.v.data;
          return _context24.a(2, {
            isEnd: !0,
            musicList: (((s = e == null ? void 0 : e.data) == null ? void 0 : s.songList) || []).map(function (o) {
              var i = o;
              return i.artistNames = i.singerList.map(function (c) {
                return c.name;
              }).join("/"), ut(i);
            })
          });
      }
    }, _callee24);
  }));
  return _ct.apply(this, arguments);
}
function ut(t) {
  return {
    id: t.contentId,
    title: t.songName,
    artist: t.artistNames,
    album: t.album,
    duration: t.duration,
    artwork: t.img3,
    albumId: t.albumId,
    lrc: t.lrcUrl,
    singerList: t.singerList,
    resourceType: String(t.resourceType),
    copyrightId: t.copyrightId
  };
}
function mt(_x30, _x31) {
  return _mt.apply(this, arguments);
}
function _mt() {
  _mt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee25(t, n) {
    var s, o, i, c, e, r, _iterator3, _step3, u, a, _t9;
    return _regenerator().w(function (_context25) {
      while (1) switch (_context25.p = _context25.n) {
        case 0:
          _context25.n = 1;
          return p.default.get("https://app.c.nf.migu.cn/bmw/singer/song/v1.0?pageNo=".concat(n || 1, "&singerId=").concat(t.id, "&type=1"));
        case 1:
          e = _context25.v.data;
          r = ((i = (o = (s = e == null ? void 0 : e.data) == null ? void 0 : s.contents) == null ? void 0 : o[0]) == null ? void 0 : i.contents) || [];
          _iterator3 = _createForOfIteratorHelper((c = e == null ? void 0 : e.data) == null ? void 0 : c.contents);
          _context25.p = 2;
          _iterator3.s();
        case 3:
          if ((_step3 = _iterator3.n()).done) {
            _context25.n = 5;
            break;
          }
          u = _step3.value;
          if (!((u == null ? void 0 : u.view) === "ZJ-Singer-Song-Scroll")) {
            _context25.n = 4;
            break;
          }
          r = u.contents;
          return _context25.a(3, 5);
        case 4:
          _context25.n = 3;
          break;
        case 5:
          _context25.n = 7;
          break;
        case 6:
          _context25.p = 6;
          _t9 = _context25.v;
          _iterator3.e(_t9);
        case 7:
          _context25.p = 7;
          _iterator3.f();
          return _context25.f(7);
        case 8:
          if (r) {
            _context25.n = 9;
            break;
          }
          return _context25.a(2, {
            isEnd: !0,
            musicList: []
          });
        case 9:
          a = r.map(function (u) {
            var d = u.songItem;
            return d.artistNames = d.singerList.map(function (j) {
              return j.name;
            }).join("/"), l(d);
          });
          return _context25.a(2, {
            isEnd: a.length < 20,
            data: a
          });
      }
    }, _callee25, null, [[2, 6, 7, 8]]);
  }));
  return _mt.apply(this, arguments);
}
function gt(_x32, _x33) {
  return _gt.apply(this, arguments);
}
function _gt() {
  _gt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee26(t, n) {
    var a, s, e, r;
    return _regenerator().w(function (_context26) {
      while (1) switch (_context26.n) {
        case 0:
          _context26.n = 1;
          return M(t.id, n || 1);
        case 1:
          e = _context26.v;
          r = ((a = e == null ? void 0 : e.data) == null ? void 0 : a.contents) || [];
          return _context26.a(2, r.length === 0 ? {
            isEnd: !0,
            data: []
          } : {
            isEnd: !((s = e == null ? void 0 : e.data.header) != null && s.hasNext),
            data: r.map(function (o) {
              return {
                id: o.resId,
                title: o.txt,
                artist: o.txt2,
                artwork: o.img,
                resourceType: o.resType === "1" ? "5" : "2003"
              };
            })
          });
      }
    }, _callee26);
  }));
  return _gt.apply(this, arguments);
}
function lt(_x34, _x35) {
  return _lt.apply(this, arguments);
}
function _lt() {
  _lt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee27(t, n) {
    var e;
    return _regenerator().w(function (_context27) {
      while (1) switch (_context27.n) {
        case 0:
          _context27.n = 1;
          return D(t.id, n || 1);
        case 1:
          e = _context27.v;
          if (!e) {
            _context27.n = 2;
            break;
          }
          return _context27.a(2, {
            isEnd: (e == null ? void 0 : e.data.totalCount) - 50 * n <= 0,
            musicList: (e == null ? void 0 : e.data.songList.map(function (r) {
              return l(r);
            })) || []
          });
        case 2:
          return _context27.a(2);
      }
    }, _callee27);
  }));
  return _lt.apply(this, arguments);
}
function pt(_x36) {
  return _pt.apply(this, arguments);
}
function _pt() {
  _pt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee28(t) {
    var n;
    return _regenerator().w(function (_context28) {
      while (1) switch (_context28.n) {
        case 0:
          _context28.n = 1;
          return S(t.id);
        case 1:
          n = _context28.v;
          if (!n.success) {
            _context28.n = 2;
            break;
          }
          return _context28.a(2, {
            rawLrc: (n == null ? void 0 : n.lrc) || ""
          });
        case 2:
          return _context28.a(2);
      }
    }, _callee28);
  }));
  return _pt.apply(this, arguments);
}
function dt() {
  return _dt.apply(this, arguments);
}
function _dt() {
  _dt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee29() {
    return _regenerator().w(function (_context29) {
      while (1) switch (_context29.n) {
        case 0:
          _context29.n = 1;
          return Q();
        case 1:
          return _context29.a(2, _context29.v.data.contents.map(function (n) {
            var e = n.style,
              r = n.contents.map(function (a) {
                return {
                  title: a.rankName,
                  id: a.rankId,
                  coverImg: a.imageUrl
                };
              });
            return {
              title: e,
              data: r
            };
          }));
      }
    }, _callee29);
  }));
  return _dt.apply(this, arguments);
}
function ft(_x37) {
  return _ft.apply(this, arguments);
}
function _ft() {
  _ft = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee30(t) {
    var n;
    return _regenerator().w(function (_context30) {
      while (1) switch (_context30.n) {
        case 0:
          _context30.n = 1;
          return $(t.id, t.page);
        case 1:
          n = _context30.v;
          return _context30.a(2, n ? {
            isEnd: !n.data.hasNextPage,
            musicList: n.data.contents.map(function (e) {
              var r = JSON.parse(e.songData);
              return r.artistNames = r.singerList.map(function (a) {
                return a.name;
              }).join("/"), r.img3 = r.img3.replace("https://d.musicapp.migu.cn", ""), l(r);
            }) || []
          } : {
            isEnd: !0,
            musicList: []
          });
      }
    }, _callee30);
  }));
  return _ft.apply(this, arguments);
}
function yt() {
  return _yt.apply(this, arguments);
}
function _yt() {
  _yt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee31() {
    var t, n, e;
    return _regenerator().w(function (_context31) {
      while (1) switch (_context31.n) {
        case 0:
          _context31.n = 1;
          return I(!0);
        case 1:
          t = _context31.v;
          n = t.data.contentItemList.map(function (r) {
            return {
              title: r.tagName,
              id: r.tagId
            };
          });
          e = t.data.moreTag.map(function (r) {
            var a = r.title,
              s = r.tagList.map(function (o) {
                return {
                  title: o.tagName,
                  id: o.tagId
                };
              });
            return {
              title: a,
              data: s
            };
          });
          return _context31.a(2, {
            pinned: n,
            data: e
          });
      }
    }, _callee31);
  }));
  return _yt.apply(this, arguments);
}
function ht(_x38, _x39) {
  return _ht.apply(this, arguments);
}
function _ht() {
  _ht = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee32(t, n) {
    var e, a, r;
    return _regenerator().w(function (_context32) {
      while (1) switch (_context32.n) {
        case 0:
          if (t.id) {
            _context32.n = 2;
            break;
          }
          _context32.n = 1;
          return I(!1);
        case 1:
          a = _context32.v;
          e = a == null ? void 0 : a.data.contentItemList[0].tagId;
        case 2:
          _context32.n = 3;
          return A(t.id || e, n || 1);
        case 3:
          r = _context32.v;
          return _context32.a(2, r ? {
            isEnd: !r.data.hasNext,
            data: r.data.contentItemList.map(function (a) {
              return a.playDesc = a.playNum, a.playDesc.includes("\u4E07") ? a.playNum = Number(a.playDesc.split("\u4E07")[0]) * 1e4 : a.playDesc.includes("\u5343") ? a.playNum = Number(a.playDesc.split("\u5343")[0]) * 1e3 : a.playNum = Number(a.playDesc), {
                id: a.playlistId,
                title: a.title,
                artwork: a.imageUrl,
                playCount: a.playNum
              };
            }) || []
          } : {
            isEnd: !0,
            musicList: []
          });
      }
    }, _callee32);
  }));
  return _ht.apply(this, arguments);
}
function bt(_x40) {
  return _bt.apply(this, arguments);
}
function _bt() {
  _bt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee33(t) {
    var n, e, r;
    return _regenerator().w(function (_context33) {
      while (1) switch (_context33.n) {
        case 0:
          if (!(!t.startsWith("http://") && !t.startsWith("https://"))) {
            _context33.n = 1;
            break;
          }
          return _context33.a(2, []);
        case 1:
          _context33.n = 2;
          return v(t);
        case 2:
          n = _context33.v;
          if (!(n.data.successCount === 0)) {
            _context33.n = 3;
            break;
          }
          return _context33.a(2, []);
        case 3:
          e = n.data.haveCopyrightSongs.map(function (a) {
            return a.contentId;
          }).join(",") || "";
          if (e) {
            _context33.n = 4;
            break;
          }
          return _context33.a(2, []);
        case 4:
          _context33.n = 5;
          return P(e);
        case 5:
          r = _context33.v;
          return _context33.a(2, r.data ? r.data.map(function (a) {
            return a.artistNames = a.singerList.map(function (s) {
              return s.name;
            }).join("/"), l(a);
          }) : []);
      }
    }, _callee33);
  }));
  return _bt.apply(this, arguments);
}
function It(_x41) {
  return _It.apply(this, arguments);
}
function _It() {
  _It = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee34(t) {
    var r, a, s, n, e;
    return _regenerator().w(function (_context34) {
      while (1) switch (_context34.n) {
        case 0:
          e = function _e(o) {
            var i;
            return {
              id: o.commentId,
              nickName: o.user.nickName,
              avatar: o.user.middleIcon,
              comment: o.commentInfo,
              like: o.opNumItem.thumbNum,
              replies: ((i = o == null ? void 0 : o.replyComments) == null ? void 0 : i.map(function (c) {
                return {
                  id: c.replyId,
                  nickName: c.user.nickName,
                  avatar: c.user.middleIcon,
                  comment: c.replyInfo,
                  like: c.haveThumb
                };
              })) || []
            };
          };
          _context34.n = 1;
          return x(t.id, 2, 50);
        case 1:
          n = _context34.v;
          if (n.data.hotComments) {
            _context34.n = 2;
            break;
          }
          return _context34.a(2, {
            isEnd: !0,
            data: []
          });
        case 2:
          return _context34.a(2, {
            isEnd: !0,
            data: ((s = n.data.hotComments) == null ? void 0 : s.map(e).concat((a = (r = n == null ? void 0 : n.data) == null ? void 0 : r.comments) == null ? void 0 : a.map(e))) || []
          });
      }
    }, _callee34);
  }));
  return _It.apply(this, arguments);
}
function wt(_x42, _x43) {
  return _wt.apply(this, arguments);
}
function _wt() {
  _wt = _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee35(t, n) {
    var r, e;
    return _regenerator().w(function (_context35) {
      while (1) switch (_context35.n) {
        case 0:
          _context35.n = 1;
          return _(t.id);
        case 1:
          e = _context35.v;
          return _context35.a(2, {
            isEnd: !0,
            musicList: ((r = e == null ? void 0 : e.data) == null ? void 0 : r.songList.map(function (a) {
              return a.artistNames = a.singerList.map(function (s) {
                return s.name;
              }).join("/"), l(a);
            })) || []
          });
      }
    }, _callee35);
  }));
  return _wt.apply(this, arguments);
}
module.exports = {
  platform: "\u54AA\u5495",
  version: "0.2.3",
  author: "Domdkw",
  primaryKey: ["id", "singerId", "albumId", "copyrightId", "resourceType", "toneFlag", "totalCount"],
  cacheControl: "cache",
  srcUrl: "https://gitee.com/Domdkw/MusicFree-migu/raw/master/dist/migu-plugin.js",
  supportedSearchType: ["music", "album", "sheet", "artist", "lyric"],
  hints: {
    importMusicSheet: ["\u82E5\u53EA\u5BFC\u5165\u4E86\u90E8\u5206\u6B4C\u66F2\uFF0C\u4EE3\u8868\u54AA\u5495\u97F3\u4E50\u6CA1\u6709\u6B64\u6B4C\u66F2\u7684\u7248\u6743\uFF0C\u65E0\u6CD5\u64AD\u653E\u3002\u5176\u4ED6\u95EE\u9898\u8BF7\u54A8\u8BE2560952574"]
  },
  search: function search(t, n, e) {
    return _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee15() {
      var _t, _t2, _t3, _t4, _t5;
      return _regenerator().w(function (_context15) {
        while (1) switch (_context15.n) {
          case 0:
            t = encodeURIComponent(t);
            if (!(e === "music")) {
              _context15.n = 2;
              break;
            }
            _context15.n = 1;
            return tt(t, n);
          case 1:
            _t = _context15.v;
            _context15.n = 15;
            break;
          case 2:
            if (!(e === "album")) {
              _context15.n = 4;
              break;
            }
            _context15.n = 3;
            return at(t, n);
          case 3:
            _t2 = _context15.v;
            _context15.n = 14;
            break;
          case 4:
            if (!(e === "artist")) {
              _context15.n = 6;
              break;
            }
            _context15.n = 5;
            return st(t, n);
          case 5:
            _t3 = _context15.v;
            _context15.n = 13;
            break;
          case 6:
            if (!(e === "sheet")) {
              _context15.n = 8;
              break;
            }
            _context15.n = 7;
            return nt(t, n);
          case 7:
            _t4 = _context15.v;
            _context15.n = 12;
            break;
          case 8:
            if (!(e === "lyric")) {
              _context15.n = 10;
              break;
            }
            _context15.n = 9;
            return et(t, n);
          case 9:
            _t5 = _context15.v;
            _context15.n = 11;
            break;
          case 10:
            _t5 = {
              data: [],
              isEnd: !0
            };
          case 11:
            _t4 = _t5;
          case 12:
            _t3 = _t4;
          case 13:
            _t2 = _t3;
          case 14:
            _t = _t2;
          case 15:
            return _context15.a(2, _t);
        }
      }, _callee15);
    }))();
  },
  getMediaSource: it,
  getAlbumInfo: function getAlbumInfo(t, n) {
    return _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee16() {
      return _regenerator().w(function (_context16) {
        while (1) switch (_context16.n) {
          case 0:
            if (!(t.resourceType === "2003")) {
              _context16.n = 2;
              break;
            }
            _context16.n = 1;
            return ct(t, n);
          case 1:
            return _context16.a(2, _context16.v);
          case 2:
            if (!(t.resourceType === "5")) {
              _context16.n = 4;
              break;
            }
            _context16.n = 3;
            return wt(t, n);
          case 3:
            return _context16.a(2, _context16.v);
          case 4:
            return _context16.a(2);
        }
      }, _callee16);
    }))();
  },
  getArtistWorks: function getArtistWorks(t, n, e) {
    return _asyncToGenerator(/*#__PURE__*/_regenerator().m(function _callee17() {
      var _t6, _t7;
      return _regenerator().w(function (_context17) {
        while (1) switch (_context17.n) {
          case 0:
            if (!(e === "music")) {
              _context17.n = 2;
              break;
            }
            _context17.n = 1;
            return mt(t, n);
          case 1:
            _t6 = _context17.v;
            _context17.n = 6;
            break;
          case 2:
            if (!(e === "album")) {
              _context17.n = 4;
              break;
            }
            _context17.n = 3;
            return gt(t, n);
          case 3:
            _t7 = _context17.v;
            _context17.n = 5;
            break;
          case 4:
            _t7 = {
              isEnd: !0,
              data: []
            };
          case 5:
            _t6 = _t7;
          case 6:
            return _context17.a(2, _t6);
        }
      }, _callee17);
    }))();
  },
  getLyric: pt,
  getTopLists: dt,
  getTopListDetail: ft,
  getMusicSheetInfo: lt,
  getRecommendSheetTags: yt,
  getRecommendSheetsByTag: ht,
  importMusicSheet: bt,
  getMusicComments: It
};
