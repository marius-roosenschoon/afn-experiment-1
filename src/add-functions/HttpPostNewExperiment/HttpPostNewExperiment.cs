using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using HttpPostNewExperiment.Models;

namespace HttpPostNewExperiment
{
    public static class HttpPostNewExperiment
    {
        [FunctionName("HttpPostNewExperiment")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function is processing a request.");

            string name = req.Query["name"];
            string surname = req.Query["surname"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            name = name ?? data?.name;
            surname = surname ?? data?.surname;

            //string responseMessage = string.IsNullOrEmpty(name)
            //    ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
            //    : $"Hello, {name} {surname}. This HTTP triggered function executed successfully.";

            //return new OkObjectResult(responseMessage);

            string fullname = name + " " + surname;

            Response json = new Response();
            json.message_success = "true";
            json.message_fullname = fullname;
            var jsonResponse = JsonConvert.SerializeObject(json);

            var response = new OkObjectResult(jsonResponse);
            response.ContentTypes.Add("application/json");

            log.LogInformation("Responding with: " + jsonResponse);
            log.LogInformation("C# HTTP trigger function is complete.");

            return response;
        }
    }
}
