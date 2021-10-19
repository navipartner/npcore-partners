# Documenting APIs

## OpenAPI files
You can place openapi json files in the "/Documentation/openapi/" folder  
Instead of writing everything from scratch you can use a tool such as:  
https://github.com/microsoft/OpenAPI.NET.OData  
To generate the rough scaffolding for your API.

Once you have the scaffolding, you can use a vscode extension such as:  
https://marketplace.visualstudio.com/items?itemName=42Crunch.vscode-openapi  
To make sure it looks right via the preview command and to provide you with intellisense and schema validation.  
Make sure your file has the proper explanations needed for an external party to understand how to consume it.

### Server List and Authorization

Since we have 3 different URL structures in scope:
* OnPrem
* Crane Container
* MS Cloud

and two authorization mechanisms:
* Basic Auth
* OAuth

We have some premade openAPI config section you can copy/paste into your specific openapi.json file to easily get the proper endpoints and auth look & feel:

```
  "servers": [
    {
      "url": "https://api.businesscentral.dynamics.com/v2.0/{environmentName}/api/v2.0/",
      "variables": {
        "environmentName": {
          "default": "REPLACE_ME",
          "description": "Environment name"
        }
      },
      "description": "Microsoft BC Cloud"
    },
    {
      "url": "https://{tenantId}.dynamics-retail.com:7069/BC/api/v2.0/",
      "variables": {
        "tenantId": {
          "default": "REPLACE_ME",
          "description": "Tenant ID"
        }
      },
      "description": "NaviPartner OnPrem"
    },
    {
      "url": "https://{containerName}.dynamics-retail.net:443/BC/api/v2.0/",
      "variables": {
        "containerName": {
          "default": "REPLACE_ME",
          "description": "Container Name"
        }
      },
      "description": "NaviPartner Crane Container"
    }   
  ]
```


```
  "security": [
    {
      "BasicAuth":[],
      "OAuth2":["https://api.businesscentral.dynamics.com/.default"]
    }
  ],
  "components" {
    "securitySchemes": {
      "BasicAuth": {
        "type": "http",
        "scheme": "basic"
      },
      "OAuth2": {
        "type": "oauth2",
        "flows": {
          "authorizationCode": {
            "authorizationUrl": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
            "tokenUrl": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
            "scopes": {
              "https://api.businesscentral.dynamics.com/.default": "Grants API access"
            }
          }
        }
      }
    }
  }
```


## Linking to API sandbox
You can link to the API sandbox that parses openAPI files from any published markdown articles by writing a non-validated relative link (any link starting with "/") such as:  
``
[API Playground](/api/sandbox.html?spec=openapi_file.json)
``

It is recommended that you add a markdown article for your APIGroup under the /product/api/methods folder that links to the sandbox and any other relevant articles.

It is also recommended that you keep each APIGroup documented in the same openapi file.


