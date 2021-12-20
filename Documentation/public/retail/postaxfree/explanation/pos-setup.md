# POS flows

## Enabling Tax free in active sale

The recommended POS setup consists of two main buttons.

![POS main two buttons for tax-free setup](../images/pos-main-buttons.png "Main buttons")

- **Toggle Tax Free** allows the salesperson to manually switch tax free on or off. The button also contains the current tax free status in the active sale (enabled or disabled), regardless of whether it was enabled manually, or via EFT IIN suggestion confirmation.

You can also confirm the prompt that pops up if a customer pays with an EFT card that is detected as foreign inside a sale that's considered eligible. When tax free has been enabled in an active sale, the issue tax-free voucher flow will start immediately after the sale has ended. 

>[!Tip]
> To show the current status inside the button caption specify data extension: {{TAX_FREE.Status}}.      
>For example: Toggle Tax Free <b><small>Status: {{TAX_FREE.Status}}</small></b>

- **Tax Free Menu** contains several actions:

>[!Note]
> All tax-free buttons use the same POS action code - **TAX_FREE**.

    - **Voucher List** - opens up the list of existing tax-free vouchers.
    - **Unit List** - opens up the setup of tax-free units.
    - **Audit Roll** - 
    - **Consolidate** - opens up the consolidate voucher window from which you can search for, and add, sales receipts to consolidate.
    - **Print Last Voucher** - reprints the last voucher issued in the current session.


## Issuing Tax Free for Older Sales

Tax-free vouchers can be issued for already completed sales from the audit roll. If the sale is eligible, not past their expiration date 

## Reissue tax-free voucher

Reissuing a tax-free voucher implies that the existing voucher has been voided, and that its data is used for reissuing a new one. automatically voiding the existing voucher and reissuing a new one with the same information. It can either be done on the list of tax-free vouchers, or via the prompt that occurs if trying to issue a tax-free voucher for a sale that already has another active voucher linked. This is only possible if the voucher hasn't already been used and the void time limit on the tax-fee service that was used for the voucher hasn't expired.

It's only to be used if the end customer (voucher owner) is in the store, either due to technical issues, or because they need a voucher replacement. 

## Void tax-free voucher

A void voucher is the one which isn't valid any longer. 

Voiding vouchers can be done manually, or on the list of tax-free vouchers, by selecting the option described in [Issuing Tax Free for older sales](), or by confirming the prompt that automatically happens if someone tries to reverse a sales receipt linked to an active tax-free voucher.  

Voiding a voucher is only possible if the voucher hasn't already been used, and the expiration date on the tax-free service that was used for the voucher hasn't yet been reached. 

# POS actions

## Traveler information capture 

When issuing a tax-free voucher, the traveler information will be collected. 

1. In the first prompt, you need to state whether the end customer has a Global Blue identifier.
2. If you click **Yes**, a list of different identification types are opened, and if you click **No** you are immediately redirected to the manual info capture. 
3. When selecting a Global Blue identifier type, the **Global Blue Member Card** is meant for end customers who are already registered with Global Blue, and either have a membership card, and scannable barcode, or a mobile number, or passport information that can be looked up. incorrect
4. After selecting one of these three types and entering the appropriate value, a lookup attempt is made in the Global Blue system. If a match is found, the salesperson is prompted to confirm it. If not, the capture flow is restarted. 


## The Reprint Last action

The **Reprint Last** POS action is used for reprinting the last attempt that was issued for the current user's login session in the Business Central. This is only stored as long as the relevant session is active. If the user is disconnected, logged out or similar, the session is restarted, and the voucher is terminated. 

If a voucher print is needed and the reprint is no longer an option, reissuing the voucher is the only solution. 

## Voucher lookup

The POS action for opening the list of vouchers displays all issued tax-free vouchers in the system, and allow you to search via the voucher document number. 
- **Void voucher**
- **Print voucher** - doesn't work on POS units that are set up for the Global Blue solution since it doesn't allow reprints of the existing vouchers except via the **Reprint Last** action. If you wish to reprint, you should use the **Reissue** action instead. 
- **Reissue voucher** - To reissue a tax-free voucher implies automatically voiding the existing voucher and reissuing a new one with the same information. It can either be done on the list of tax-free vouchers, or via the prompt that occurs if trying to issue a tax-free voucher for a sale that already has another active voucher linked. This is only possible if the voucher hasn't already been used and the void time limit on the tax-fee service that was used for the voucher hasn't expired.
- **Search sale links** - opens up another window in which you can easily see and search for either the sales receipt number used by NP Retail, or the external voucher number used by Global Blue. It also illustrates the one-to-many relationship that can exist if consolidation has been used, especially if reissue has been used on top. 


## Receipt Consolidation

You can consolidate multiple sales receipts into one tax-free voucher. This is done via the **Consolidate** POS action. This action opens up the consolidation window from where you can search for and add one or more sales receipts to consolidate. 

Whenever you add a new receipt, the Audit Roll opens up, allowing you to find a specific sales receipt and add it. 




