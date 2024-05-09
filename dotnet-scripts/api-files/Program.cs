using AStar.ASPNet.Extensions.PipelineExtensions;
using AStar.ASPNet.Extensions.ServiceCollectionExtensions;

namespace {ApiProjectName};

public static class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        _ = builder.AddLogging();
        _ = builder.Services.ConfigurePipeline();
        ConfigureServices(builder.Services);

        var app = builder.Build();
        _ = app.ConfigurePipeline();
        ConfigurePipeline(app);

        app.Run();
    }

    private static IServiceCollection ConfigureServices(IServiceCollection services)
        // Additional configuration can be performed here
        => services;

    private static WebApplication ConfigurePipeline(WebApplication app)
        // Additional configuration can be performed here
        => app;
}
