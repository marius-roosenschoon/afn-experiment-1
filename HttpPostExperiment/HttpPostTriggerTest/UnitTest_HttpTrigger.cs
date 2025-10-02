using FunctionTestHelper;
using HttpPostExperiment;
using HttpPostExperiment.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;

namespace HttpPostTriggerTest
{
    [TestClass]
    public class UnitTest_HttpTrigger
    {
        private readonly ILogger _logger;

        public string FirstName = string.Empty;
        public string LastName = string.Empty;
        public string ExpectedResponse = string.Empty;
        private ILoggerFactory loggerFactory;

        public UnitTest_HttpTrigger()
        {
            FirstName = "Marius";
            LastName = "Roosenschoon";

            string name = FirstName;
            string surname = LastName;
            string fullname = name + " " + surname;

            Response json = new Response();
            json.message_success = "true";
            json.message_fullname = fullname;
            ExpectedResponse = JsonConvert.SerializeObject(json);

            loggerFactory = new LoggerFactory();    
            _logger = loggerFactory.CreateLogger<HttpTriggerPostExperiment>();
        }

        [TestMethod]
        public void TestMethod_Request1()
        {
            Request reqObj = new Request();
            reqObj.firstname = FirstName;
            reqObj.lastname = LastName;
            string req = JsonConvert.SerializeObject(reqObj);

            var query = new Dictionary<string, StringValues>();

            // Arrange
            var body = new MemoryStream(Encoding.ASCII.GetBytes(req));
            var context = new Mock<FunctionContext>();
            var request = new FakeHttpRequestData(
                            context.Object,
                            new Uri("https://stackoverflow.com"),
                            body);

            // Act
            LoggerFactory loggerFactory = new LoggerFactory();

            var function = new HttpTriggerPostExperiment(loggerFactory);
            var result = function.Run(request);
            result.Body.Position = 0;

            // Assert
            var reader = new StreamReader(result.Body);
            var responseBody = reader.ReadToEnd();
            Assert.IsNotNull(result);
            Assert.AreEqual(HttpStatusCode.OK, result.StatusCode);
            Assert.AreEqual(ExpectedResponse, responseBody);

            Console.WriteLine(responseBody);
        }


    }
}
