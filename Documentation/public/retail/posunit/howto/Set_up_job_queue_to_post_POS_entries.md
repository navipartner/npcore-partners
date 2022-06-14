# Set up job queue to post POS entries

After sale is done, the POS entry is created. This entry has **Post item entry status** and **Post Entry Status** - UNPOSTED. Entry can be posted manually, but most usual is to create jobs in **Job Queue Entry** which will post entry. There are three jobs which needs to be set up:   
1. **NPR POS Post Item Entries** - Code Unit 6059770 - this job is used for posting sale to item ledger entries. It is setup usually with **No. of minutes between runs** = 1 so inventory in all locations can be updated in every minute.

![6059770](../images/6059770.PNG)

2. **NPR POS Post GL entries** – Code Unit 6014699 – This job is used for posting sales and payment to G/L accounts.

![6059770](../images/6014699.PNG)

3.	**NPR Post Inventory Cost to G/L** – Code Unit 6014683 – This job is used for posting inventory to G/L accounts.