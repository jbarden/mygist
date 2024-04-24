using System.IO.Abstractions;
using System.Text.Json.Serialization;
using AStar.ASPNet.Extensions.Handlers;
using AStar.ASPNet.Extensions.PipelineExtensions;
using AStar.ASPNet.Extensions.ServiceCollectionExtensions;
using AStar.Clean.V1.Files.API.Services;
using AStar.Infrastructure.Data;

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

        app.Run();
    }

    private static void ConfigureServices(IServiceCollection services)
    {
        _ = services.AddDbContext<FilesContext>();
        _ = services.AddSwaggerGenNewtonsoftSupport();
        _ = services.AddSingleton<IFileSystem, FileSystem>()
                    .AddSingleton<IImageService, ImageService>();
    }
}
