# Replication Module Introduction
You can use the Replication Module to import data from one company to another (companies can be in the same database or in different Business Central databases).

Depending on how you set up the Replication Module, you can:

- import data in Store companies from a Master (HQ) company.
- import data in a new Business Central database from an existing Business Central database.
- synchronize your application with a database used by another application.     

There is a predefined configuration created automatically when the **Replication Setup List** page is first opened, but you can also configure mapping of each table and column.

Newly created or modified records are identified with the field **Replication Counter** which is populated based on the [Business Central timestamp field](https://docs.microsoft.com/en-us/dynamics-nav/how-to--use-a-timestamp-field).

Import of new or modified records is handled by making API requests to the From Company (source company). API requests are based on [Business Central Custom API pages](https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api).


