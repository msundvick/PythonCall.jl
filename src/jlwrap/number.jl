const pyjlnumbertype = pynew()
const pyjlcomplextype = pynew()
const pyjlrealtype = pynew()
const pyjlrationaltype = pynew()
const pyjlintegertype = pynew()

struct pyjlnumber_op{OP}
    op :: OP
end
(op::pyjlnumber_op)(self) = Py(op.op(self))
function (op::pyjlnumber_op)(self, other_::Py)
    if pyisjl(other_)
        other = pyjlvalue(other_)
    else
        other = @pyconvert(Number, other_, return Py(pybuiltins.NotImplemented))
    end
    Py(op.op(self, other))
end
function (op::pyjlnumber_op)(self, other_::Py, other2_::Py)
    if pyisjl(other_)
        other = pyjlvalue(other_)
    else
        other = @pyconvert(Number, other_, return Py(pybuiltins.NotImplemented))
    end
    if pyisjl(other2_)
        other2 = pyjlvalue(other2_)
    else
        other2 = @pyconvert(Number, other2_, return Py(pybuiltins.NotImplemented))
    end
    Py(op.op(self, other, other2))
end
pyjl_handle_error_type(op::pyjlnumber_op, self, exc) = exc isa MethodError && exc.f === op.op ? pybuiltins.TypeError : PyNULL

struct pyjlnumber_rev_op{OP}
    op :: OP
end
function (op::pyjlnumber_rev_op)(self, other_::Py)
    if pyisjl(other_)
        other = pyjlvalue(other_)
    else
        other = @pyconvert(Number, other_, return Py(pybuiltins.NotImplemented))
    end
    Py(op.op(other, self))
end
function (op::pyjlnumber_rev_op)(self, other_::Py, other2_::Py)
    if pyisjl(other_)
        other = pyjlvalue(other_)
    else
        other = @pyconvert(Number, other_, return Py(pybuiltins.NotImplemented))
    end
    if pyisjl(other2_)
        other2 = pyjlvalue(other2_)
    else
        other2 = @pyconvert(Number, other2_, return Py(pybuiltins.NotImplemented))
    end
    Py(op.op(other, self, other2))
end
pyjl_handle_error_type(op::pyjlnumber_rev_op, self, exc) = exc isa MethodError && exc.f === op.op ? pybuiltins.TypeError : PyNULL

pyjlreal_trunc(self::Real) = Py(trunc(Integer, self))
pyjl_handle_error_type(::typeof(pyjlreal_trunc), self, exc::MethodError) = exc.f === trunc ? pybuiltins.TypeError : PyNULL

pyjlreal_floor(self::Real) = Py(floor(Integer, self))
pyjl_handle_error_type(::typeof(pyjlreal_floor), self, exc::MethodError) = exc.f === floor ? pybuiltins.TypeError : PyNULL

pyjlreal_ceil(self::Real) = Py(ceil(Integer, self))
pyjl_handle_error_type(::typeof(pyjlreal_ceil), self, exc::MethodError) = exc.f === ceil ? pybuiltins.TypeError : PyNULL

function pyjlreal_round(self::Real, ndigits_::Py)
    ndigits = pyconvertarg(Union{Int,Nothing}, ndigits_, "ndigits")
    if ndigits === nothing
        Py(round(Integer, self))
    else
        Py(round(self; digits = ndigits))
    end
end
pyjl_handle_error_type(::typeof(pyjlreal_round), self, exc::MethodError) = exc.f === round ? pybuiltins.TypeError : PyNULL

function init_jlwrap_number()
    jl = pyjuliacallmodule
    filename = "$(@__FILE__):$(1+@__LINE__)"
    pybuiltins.exec(pybuiltins.compile("""
    class NumberValue(AnyValue):
        __slots__ = ()
        __module__ = "juliacall"
        def __bool__(self):
            return not self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(iszero))))
        def __add__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(+))), other)
        def __sub__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(-))), other)
        def __mul__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(*))), other)
        def __truediv__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(/))), other)
        def __floordiv__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(÷))), other)
        def __mod__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(%))), other)
        def __pow__(self, other, modulo=None):
            if modulo is None:
                return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(^))), other)
            else:
                return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(powermod))), other, modulo)
        def __lshift__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(<<))), other)
        def __rshift__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(>>))), other)
        def __and__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(&))), other)
        def __xor__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(⊻))), other)
        def __or__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(|))), other)
        def __radd__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(+))), other)
        def __rsub__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(-))), other)
        def __rmul__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(*))), other)
        def __rtruediv__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(/))), other)
        def __rfloordiv__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(÷))), other)
        def __rmod__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(%))), other)
        def __rpow__(self, other, modulo=None):
            if modulo is None:
                return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(^))), other)
            else:
                return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(powermod))), other, modulo)
        def __rlshift__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(<<))), other)
        def __rrshift__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(>>))), other)
        def __rand__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(&))), other)
        def __rxor__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(⊻))), other)
        def __ror__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_rev_op(|))), other)
        def __eq__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(==))), other)
        def __ne__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(!=))), other)
        def __le__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(≤))), other)
        def __lt__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(<))), other)
        def __ge__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(≥))), other)
        def __gt__(self, other):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(>))), other)
    class ComplexValue(NumberValue):
        __slots__ = ()
        __module__ = "juliacall"
        def __complex__(self):
            return self._jl_callmethod($(pyjl_methodnum(pycomplex)))
        @property
        def real(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(real))))
        @property
        def imag(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(imag))))
        def conjugate(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(conj))))
    class RealValue(ComplexValue):
        __slots__ = ()
        __module__ = "juliacall"
        def __float__(self):
            return self._jl_callmethod($(pyjl_methodnum(pyfloat)))
        @property
        def real(self):
            return self
        @property
        def imag(self):
            return 0
        def conjugate(self):
            return self
        def __complex__(self):
            return complex(float(self))
        def __trunc__(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlreal_trunc)))
        def __floor__(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlreal_floor)))
        def __ceil__(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlreal_ceil)))
        def __round__(self, ndigits=None):
            return self._jl_callmethod($(pyjl_methodnum(pyjlreal_round)), ndigits)
    class RationalValue(RealValue):
        __slots__ = ()
        __module__ = "juliacall"
        @property
        def numerator(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(numerator))))
        @property
        def denominator(self):
            return self._jl_callmethod($(pyjl_methodnum(pyjlnumber_op(denominator))))
    class IntegerValue(RationalValue):
        __slots__ = ()
        __module__ = "juliacall"
        def __int__(self):
            return self._jl_callmethod($(pyjl_methodnum(pyint)))
        def __index__(self):
            return self.__int__()
        @property
        def numerator(self):
            return self
        @property
        def denominator(self):
            return 1
    import numbers
    numbers.Number.register(NumberValue)
    numbers.Complex.register(ComplexValue)
    numbers.Real.register(RealValue)
    numbers.Rational.register(RationalValue)
    numbers.Integral.register(IntegerValue)
    del numbers
    """, filename, "exec"), jl.__dict__)
    pycopy!(pyjlnumbertype, jl.NumberValue)
    pycopy!(pyjlcomplextype, jl.ComplexValue)
    pycopy!(pyjlrealtype, jl.RealValue)
    pycopy!(pyjlrationaltype, jl.RationalValue)
    pycopy!(pyjlintegertype, jl.IntegerValue)
end

pyjl(v::Number) = pyjl(pyjlnumbertype, v)
pyjl(v::Complex) = pyjl(pyjlcomplextype, v)
pyjl(v::Real) = pyjl(pyjlrealtype, v)
pyjl(v::Rational) = pyjl(pyjlrationaltype, v)
pyjl(v::Integer) = pyjl(pyjlintegertype, v)
