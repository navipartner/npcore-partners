# Import EFT reconciliation files, match and post them

Inside the EFT module every transaction from the POS terminal is recorded in **EFT Transaction Requests**. 
In certain cases the payment is rejected and it needs to be repeated.
The bank also records all transactions related to the bank account. Those transactions can be found in the teller files, for example.

In the EFT module, it is possible to import teller files and match transactions from those files with transactions from **EFT Transaction Requests**, after which the reconciliation can be posted.

To import a new reconciliation file:

1. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Recon. Provider List** and open the related link.
2. Click the plus sign at the top of the screen to create a new EFT reconciliation provider.
3. Populate the necessary fields in the **EFT Recon. Provider Card**.
4. Click the ![Lightbulb that opens the Tell Me feature](../../../images/Icons/Lightbulb_icon.png "Tell Me what you want to do") button, enter **EFT Reconciliation List** and open the related link.
5. Click the plus sign at the top of the screen to create a new EFT reconciliation.
6. Populate the necessary fields in the **EFT Reconciliation** card.
    > [!NOTE]
    > Make sure that the value in the **Provider** field has previously been created.
7. To set up the import handler, choose **Import Handlers** in the **EFT Reconciliation** card under **Related**.
8. Click **Import File**.

## Next steps

- After the import, entries can be matched with the entries in **EFT Transactions Requests**.
- Matching can be performed automatically, by clicking **Match Automatically**, or manually, by clicking **Match Manually**.
- Once the entries are matched, reconciliation can be posted with the **Post** action.

### Related links
- [Electronic Funds Transfer](../intro.md)
- [EFT lookup](../explanation/lookup.md)
