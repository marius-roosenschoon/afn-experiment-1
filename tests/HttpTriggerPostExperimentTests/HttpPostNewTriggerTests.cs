using HttpPostNewExperiment;
using HttpPostNewExperiment.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;
using Newtonsoft.Json;
using NUnit.Framework.Internal;
using System.Text;

namespace HttpTriggerPostNewExperimentTests
{
    public class Tests
    {
        public string FirstName = string.Empty;
        public string LastName = string.Empty;
        public string requestJson = string.Empty;
        public string expectedResponse = string.Empty;

        [SetUp]
        public void Setup()
        {
            FirstName = "Marius";
            LastName = "Roosenschoon";
            string fullname = FirstName + " " + LastName;

            Request requestJsonObj = new Request();
            requestJsonObj.firstname = FirstName;
            requestJsonObj.lastname = LastName;
            requestJson = JsonConvert.SerializeObject(requestJsonObj);

            Response responseJsonObj = new Response();
            responseJsonObj.message_success = "true";
            responseJsonObj.message_fullname = fullname;
            expectedResponse = JsonConvert.SerializeObject(responseJsonObj);
        }

        [Test]
        public async Task HttpTriggerPostExperiment_ReturnsOkResult_ForValidRequest()
        {
            // Arrange
            var requestBody = requestJson;
            var context = new DefaultHttpContext();
            var request = context.Request;

            request.Body = new MemoryStream(Encoding.UTF8.GetBytes(requestBody));
            request.ContentType = "application/json";

            var loggerMock = new Mock<Microsoft.Extensions.Logging.ILogger>();

            // Act
            var result = await HttpPostNewExperiment.HttpPostNewExperiment.Run(request, loggerMock.Object);

            var okResult = result as OkObjectResult;

            // Assert
            Assert.IsNotNull(result);
            Assert.IsInstanceOf<OkObjectResult>(result);

            Assert.IsNotNull(okResult);
            Assert.IsNotNull(okResult?.Value);

            string? responseBody = okResult?.Value?.ToString();
            StringAssert.AreEqualIgnoringCase(expectedResponse, responseBody);
            Console.WriteLine(responseBody);
        }

    }
}