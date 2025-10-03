using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net;
using HttpPostExperiment.Models;

namespace HttpPostExperiment
{
    public static class HttpTriggerPostExperiment
    {
        [FunctionName("HttpTriggerPostExperiment")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function is processing a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            string jsonRequest = data.ToString();
            log.LogInformation("Request: " + jsonRequest);

            string name = data.firstname;
            string surname = data.lastname;
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
