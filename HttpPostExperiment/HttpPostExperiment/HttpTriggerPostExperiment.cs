using System.Collections.Generic;
using System.IO;
using System.Net;
using HttpPostExperiment.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace HttpPostExperiment
{
    public class HttpTriggerPostExperiment
    {
        private readonly ILogger _logger;

        //public HttpTriggerPostExperiment()
        //{
        //    LoggerFactory loggerFactory = new LoggerFactory();
        //    _logger = loggerFactory.CreateLogger<HttpTriggerPostExperiment>();
        //}

        public HttpTriggerPostExperiment(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<HttpTriggerPostExperiment>();
        }

        [Function("HttpTriggerPostExperiment")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
        {
            _logger.LogInformation("C# HTTP trigger function is processing a request.");

            //var response = req.CreateResponse(HttpStatusCode.OK);
            //response.Headers.Add("Content-Type", "text/plain; charset=utf-8");

            //response.WriteString("Welcome to Azure Functions!");

            string requestBody = new StreamReader(req.Body).ReadToEnd();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            string jsonRequest = data.ToString();
            _logger.LogInformation("Request: " + jsonRequest);

            string name = data.firstname;
            string surname = data.lastname;
            string fullname = name + " " + surname;

            Response json = new Response();
            json.message_success = "true";
            json.message_fullname = fullname;
            var jsonResponse = JsonConvert.SerializeObject(json);

            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "application/json; charset=utf-8");
            response.WriteString(jsonResponse);

            _logger.LogInformation("Responding with: " + jsonResponse);
            _logger.LogInformation("C# HTTP trigger function is complete.");

            return response;
        }
    }
}
