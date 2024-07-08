# **Internal/public guidelines**

We are having more and more cases where there is a need to expose some objects to public, either to use them in PTE or requests by our partners. We discussed this topic and created guidelines for the process, some questions you can ask (yourself) when you get such case.

 - Can you write a public API? If not, can the owner of the module do
   it?
  - Can you solve the task without the public code with some trade-offs?
  - Is the customer request generic enough to fit into core instead of a PTE? 
-   Is the customer request unique enough that it will totally transform
   a core module into something super customized for the customer that
   might be brittle if core module changes later? If yes, then keeping
   it 100% in a PTE instead of using ISV tables intended for a different
   flow might be more stable (remember that PTE objects in SaaS is free,
   so tables/pages can be duplicated free of charge).
   -   Old modules
   which are missing public API and/or missing an owner can probably go
   public for backwards compatibility. Just like Microsoft has
   structured APIs in their new AL code and not in older messy code such
   as codeunit 80 etc.
   - If you are about to make a physical table
   public, remember that you might be able to limit the API surface by
   only exposing specific var parameters from table fields or creating a
   temp table and using it as a "data object" instead of exposing the
   physical working table.