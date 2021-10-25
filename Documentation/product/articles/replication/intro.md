# Introduction
You can use Replication Module to import data from one company to another (companies can be in the same database or in different Business Central databases).

Newly created or modified records are identified using field **Replication Counter** which is filled in based on the Business Central Timestamp Field:
https://docs.microsoft.com/en-us/dynamics-nav/how-to--use-a-timestamp-field

Import of new or modified records is handled by making API requests to the **From Company**. API requests are based on Business Central Custom API pages:
https://docs.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api

You can configure how to map each table and column. There is also a predefined configuration created automatically when the **Replication Setup List** page is first opened.

# Typical Use Cases
- Import data in **Store** companies from a *Master (HQ)* company.
- Import data in a new Business Central database from an existing Business Central database.
- Synchronize your application with a database used by another application.