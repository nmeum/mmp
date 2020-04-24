(import [mpd.ffi [*]] ctypes)
(require [hy.contrib.walk [let]])

(setv libmpdserver (ctypes.CDLL "libmpdserver.so"))
(setv parse libmpdserver.mpd_parse)
(setv parse.restype (ctypes.POINTER MPDCmd))
(setv freecmd libmpdserver.mpd_free_command)

(defclass Range [object]
  (defn --init-- [self start &optional end]
    (setv self.start start)
    (setv self.end end))

  (defn infinite? [self]
    (not self.end))

  (defn to-range [self]
    (if (self.infinite?)
      (raise (ValueError "Range has infinite length"))
      (range self.start self.end))))

(defclass Command [object]
  (defn --init-- [self cmd]
    (setv self.name (.decode cmd.name))
    (let [args (self.argv-list cmd.argc cmd.argv)]
      (setv self.args (list (map self.convert-argument args)))))

  (defn list? [self]
    (or (= self.name "command_list_begin")
        (= self.name "command_list_ok_begin")))

  (defn argv-list [self argc argv]
    (lfor
      idx (range argc)
      (. (get argv idx) contents)))

  (defn convert-argument [self arg]
    (let [t arg.type v arg.v]
      (cond
        [(= t MPDVal.INT) v.ival]
        [(= t MPDVal.UINT) v.uval]
        [(= t MPDVal.STR) (v.sval.decode)]
        [(= t MPDVal.FLOAT) v.fval]
        [(= t MPDVal.BOOL) v.bval]
        [(= t MPDVal.RANGE)
         (Range v.rval.start
                   (if (= -1 v.rval.end) None v.rval.end))]
        [(= t MPDVal.CMD)
         (Command v.cmdval.contents)]
        [(= t MPDVal.EXPR)
         (raise (NotImplementedError "Expression not implemented yet"))]
        [True (raise (TypeError (+ "unknown type " (string t))))]))))

(defn parse-command [string]
  (setv inptr (ctypes.c_char_p))
  (setv inptr.value (string.encode))
  (let [outptr (parse inptr)]
    (if (bool outptr)
      (let [cmd (Command outptr.contents)]
        (freecmd outptr)
        cmd)
      (raise (ValueError "not a valid MPD command")))))
