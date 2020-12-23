@testset "basic" begin
  m = Chain(Conv((3, 3), 3 => 16), Conv((3, 3), 16 => 32))
  @test outdims(m, (10, 10, 3)) == (6, 6, 32, 1)

  m = Dense(10, 5)
  @test_throws DimensionMismatch outdims(m, (5, 2); padbatch = false) == (5, 1)
  @test outdims(m, (10,)) == (5, 1)

  m = Chain(Dense(10, 8, σ), Dense(8, 5), Dense(5, 2))
  @test outdims(m, (10,)) == (2, 1)
  @test outdims(m, (10, 30); padbatch = false) == (2, 30)

  m = Chain(Dense(10, 8, σ), Dense(8, 4), Dense(5, 2))
  @test_throws DimensionMismatch outdims(m, (10,))

  m = Flux.Diagonal(10)
  @test outdims(m, (10,)) == (10, 1)

  m = Maxout(() -> Conv((3, 3), 3 => 16), 2)
  @test outdims(m, (10, 10, 3)) == (8, 8, 16, 1)

  m = flatten
  @test outdims(m, (5, 5, 3, 10); padbatch = false) == (75, 10)

  m = Chain(Conv((3, 3), 3 => 16), BatchNorm(16), flatten, Dense(1024, 10))
  @test outdims(m, (10, 10, 3, 50); padbatch = false) == (10, 50)
  @test outdims(m, (10, 10, 3, 2); padbatch = false) == (10, 2)

  m = SkipConnection(Conv((3, 3), 3 => 16; pad = 1), (mx, x) -> cat(mx, x; dims = 3))
  @test outdims(m, (10, 10, 3)) == (10, 10, 19, 1)
end

@testset "activations" begin
  @testset for f in [celu, elu, gelu, hardsigmoid, hardtanh,
                     leakyrelu, lisht, logcosh, logσ, mish,
                     relu, relu6, rrelu, selu, σ, softplus,
                     softshrink, softsign, swish, tanhshrink, trelu]
    @test outdims(Dense(10, 5, f), (10,)) == (5, 1)
  end
end

@testset "conv" begin
  m = Conv((3, 3), 3 => 16)
  @test outdims(m, (10, 10, 3)) == (8, 8, 16, 1)
  m = Conv((3, 3), 3 => 16; stride = 2)
  @test outdims(m, (5, 5, 3)) == (2, 2, 16, 1)
  m = Conv((3, 3), 3 => 16; stride = 2, pad = 3)
  @test outdims(m, (5, 5, 3)) == (5, 5, 16, 1)
  m = Conv((3, 3), 3 => 16; stride = 2, pad = 3, dilation = 2)
  @test outdims(m, (5, 5, 3)) == (4, 4, 16, 1)
  @test_throws DimensionMismatch outdims(m, (5, 5, 2))
  @test outdims(m, (5, 5, 3, 100); padbatch = false) == (4, 4, 16, 100)

  m = ConvTranspose((3, 3), 3 => 16)
  @test outdims(m, (8, 8, 3)) == (10, 10, 16, 1)
  m = ConvTranspose((3, 3), 3 => 16; stride = 2)
  @test outdims(m, (2, 2, 3)) == (5, 5, 16, 1)
  m = ConvTranspose((3, 3), 3 => 16; stride = 2, pad = 3)
  @test outdims(m, (5, 5, 3)) == (5, 5, 16, 1)
  m = ConvTranspose((3, 3), 3 => 16; stride = 2, pad = 3, dilation = 2)
  @test outdims(m, (4, 4, 3)) == (5, 5, 16, 1)

  m = DepthwiseConv((3, 3), 3 => 6)
  @test outdims(m, (10, 10, 3)) == (8, 8, 6, 1)
  m = DepthwiseConv((3, 3), 3 => 6; stride = 2)
  @test outdims(m, (5, 5, 3)) == (2, 2, 6, 1)
  m = DepthwiseConv((3, 3), 3 => 6; stride = 2, pad = 3)
  @test outdims(m, (5, 5, 3)) == (5, 5, 6, 1)
  m = DepthwiseConv((3, 3), 3 => 6; stride = 2, pad = 3, dilation = 2)
  @test outdims(m, (5, 5, 3)) == (4, 4, 6, 1)

  m = CrossCor((3, 3), 3 => 16)
  @test outdims(m, (10, 10, 3)) == (8, 8, 16, 1)
  m = CrossCor((3, 3), 3 => 16; stride = 2)
  @test outdims(m, (5, 5, 3)) == (2, 2, 16, 1)
  m = CrossCor((3, 3), 3 => 16; stride = 2, pad = 3)
  @test outdims(m, (5, 5, 3)) == (5, 5, 16, 1)
  m = CrossCor((3, 3), 3 => 16; stride = 2, pad = 3, dilation = 2)
  @test outdims(m, (5, 5, 3)) == (4, 4, 16, 1)

  m = AdaptiveMaxPool((2, 2))
  @test outdims(m, (10, 10, 3)) == (2, 2, 3, 1)

  m = AdaptiveMeanPool((2, 2))
  @test outdims(m, (10, 10, 3)) == (2, 2, 3, 1)

  m = GlobalMaxPool()
  @test outdims(m, (10, 10, 3)) == (1, 1, 3, 1)

  m = GlobalMeanPool()
  @test outdims(m, (10, 10, 3)) == (1, 1, 3, 1)

  m = MaxPool((2, 2))
  @test outdims(m, (10, 10, 3)) == (5, 5, 3, 1)
  m = MaxPool((2, 2); stride = 1)
  @test outdims(m, (5, 5, 4)) == (4, 4, 4, 1)
  m = MaxPool((2, 2); stride = 2, pad = 3)
  @test outdims(m, (5, 5, 2)) == (5, 5, 2, 1)

  m = MeanPool((2, 2))
  @test outdims(m, (10, 10, 3)) == (5, 5, 3, 1)
  m = MeanPool((2, 2); stride = 1)
  @test outdims(m, (5, 5, 4)) == (4, 4, 4, 1)
  m = MeanPool((2, 2); stride = 2, pad = 3)
  @test outdims(m, (5, 5, 2)) == (5, 5, 2, 1)
end

@testset "normalisation" begin
  m = Dropout(0.1)
  @test outdims(m, (10, 10); padbatch = false) == (10, 10)
  @test outdims(m, (10,)) == (10, 1)

  m = AlphaDropout(0.1)
  @test outdims(m, (10, 10); padbatch = false) == (10, 10)
  @test outdims(m, (10,)) == (10, 1)

  m = LayerNorm(32)
  @test outdims(m, (32, 32, 3, 16); padbatch = false) == (32, 32, 3, 16)

  m = BatchNorm(3)
  @test outdims(m, (32, 32, 3, 16); padbatch = false) == (32, 32, 3, 16)

  m = InstanceNorm(3)
  @test outdims(m, (32, 32, 3, 16); padbatch = false) == (32, 32, 3, 16)

  if VERSION >= v"1.1"
    m = GroupNorm(16, 4)
    @test outdims(m, (32, 32, 16, 16); padbatch = false) == (32, 32, 16, 16)
  end
end
