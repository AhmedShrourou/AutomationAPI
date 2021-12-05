Feature: test soap end point

  Background:
#    * url demoBaseUrl + '/soap'
# this live url should work if you want to try this on your own
    * url 'https://enathealthgate.nathealth.net:7002/EClaimsWS/services'

  Scenario Outline: soap 1.2
    Given path '/ClientManagement.ClientManagementHttpSoap12Endpoint/'
    And def requestBody = read('soapRequest.xml')
    And request requestBody
#    And set requestBody/Envelope/Body/registerClient/registerClient/adminKey = <adminKey>
    And set requestBody//Body//registerClient/adminKey = <adminKey>
    And set requestBody//Body//registerClient/hcpId = <hcpId>
    * def now = function(){ return java.lang.System.currentTimeMillis() }
    * def authKey = 'Test-' + now() + '-' + now()
    And set requestBody//Body//registerClient/authKey = authKey
    And set requestBody//Body//registerClient/publicKey = authKey
#    And set requestBody//Body//registerClient/id = <id> + now()
# soap is just an HTTP POST, so here we set the required header manually ..
    And header Content-Type = 'application/soap+xml; charset=utf-8'
    # .. and then we use the 'method keyword' instead of 'soap action'
    When method post
    Then status 200
    # note how we focus only on the relevant part of the payload and read expected XML from a file
#    And match /Envelope/Body/registerClientResponse/return == read('soapExpected.xml')
#    And print response
#    * xml errorMessage = get response /Envelope/Body/registerClientResponse/return
    * def errorMessage = $response//Body//return/errorMsg
#    And match /Envelope/Body/registerClientResponse/return/errorMsg == <expected>
#    And print errorMessage
    And match errorMessage == <expected>
#    And match response //errorMsg == <expected>

    Examples:
      | adminKey     | authKey                                | hcpId | hcpMemberId | id             | expected                       |
      | "Admin@1212" | "426d6608-4e36-4405-b59d-a0fb23311f11" | 172   | test        | "doctor172-34" | "Device is already registered" |

    @testTag
    Examples:
      | adminKey | authKey                                | hcpId | hcpMemberId | id             | expected            |
      | "test"   | "426d6608-4e36-4405-b59d-a0fb23311f11" | 172   | test        | "doctor172-34" | "Invalid admin key" |
