using System.Text.Json;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace {SolutionName}.HealthChecks;

public static class HealthCheckResponses
{
    public static async Task WriteJsonResponse(HttpContext context, HealthReport report)
    {
        context.Response.ContentType = "application/json; charset=utf-8";

        var options = new JsonWriterOptions { Indented = true };

        await using var writer = new Utf8JsonWriter(context.Response.Body, options);

        writer.WriteStartObject();
        writer.WriteString("status", report.Status.ToString());

        if(report.Entries.Count > 0)
        {
            writer.WriteStartArray("results");

            foreach(var (key, value) in report.Entries)
            {
                writer.WriteStartObject();
                writer.WriteString("key", key);
                writer.WriteString("status", value.Status.ToString());
                writer.WriteString("description", value.Description);
                writer.WriteStartArray("data");
                foreach(var (dataKey, dataValue) in value.Data)
                {
                    writer.WriteStartObject();
                    writer.WritePropertyName(dataKey);
                    JsonSerializer.Serialize(writer, dataValue, dataValue.GetType());
                    writer.WriteEndObject();
                }

                writer.WriteEndArray();
                writer.WriteEndObject();
            }

            writer.WriteEndArray();
        }

        writer.WriteEndObject();
    }
}
