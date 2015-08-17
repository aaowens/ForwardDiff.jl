using ForwardDiff

##################
# Test functions #
##################
function ackley(x)
    a, b = 20.0, -0.2
    len_recip = inv(length(x))
    sum_sqrs = zero(eltype(x))
    sum_cos = sum_sqrs
    for i in x
        sum_cos += cos(2.0*π*i)
        sum_sqrs += i*i
    end
    return (-a * exp(b * sqrt(len_recip*sum_sqrs)) -
            exp(len_recip*sum_cos) + a + e)
end

#############################
# Benchmark utility methods #
#############################
# Usage:
#
# benchmark ackley where length(x) = 10:10:100, taking the minimum of 4 trials:
# bench_fad(ackley, 10:10:100, 4)
#
# benchmark ackley where len(x) = 400, taking the minimum of 8 trials:
# bench_fad(ackley, 400, 4)

function bench_fad(f, range, repeat=3)
    g = ForwardDiff.gradient(f)
    h = ForwardDiff.hessian(f)

    # warm up
    bench_range(f, range, 1)
    bench_range(g, range, 1)
    bench_range(h, range, 1)

    # actual
    return Dict(
        :ftimes => bench_range(f,range,repeat),
        :gtimes => bench_range(g,range,repeat),
        :htimes => bench_range(h,range,repeat)
    )
end

function bench_func(f, xlen, repeat)
    x=rand(xlen)
    min_time = Inf
    for i in 1:repeat
        this_time = (tic(); f(x); toq())
        min_time = min(this_time, min_time)
    end
    return min_time
end

function bench_range(f, range, repeat=3)
    return [bench_func(f, xlen, repeat) for xlen in range]
end
