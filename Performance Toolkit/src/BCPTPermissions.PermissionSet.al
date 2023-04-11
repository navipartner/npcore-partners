permissionset 88000 "NPR BCPT Permissions"
{
    Caption = 'NP BCPT Permissions';
    Assignable = true;
    Permissions = tabledata "NPR BCPT Initialize Data Setup" = RIMD,
        table "NPR BCPT Initialize Data Setup" = X,
        codeunit "NPR BCPT Initialize Data" = X,
        codeunit "NPR BCPT Library - EFT" = X,
        codeunit "NPR BCPT Library - POS Mock" = X,
        codeunit "NPR BCPT Library POS Post Mock" = X,
        codeunit "NPR BCPT Library POSMasterData" = X,
        codeunit "NPR BCPT Membership Event Subs" = X,
        codeunit "NPR BCPT Misc. Event Subs" = X,
        codeunit "NPR BCPT POS Balancing EOD" = X,
        codeunit "NPR BCPT POS Credit Sale" = X,
        codeunit "NPR BCPT POS Direct Sale Cash" = X,
        codeunit "NPR BCPT POS Direct Sale EFT" = X,
        codeunit "NPR BCPT POS DS Create Member" = X,
        codeunit "NPR BCPT POS DS Ticket Issue" = X,
        codeunit "NPR BCPT POS DS Total Disc Amt" = X,
        codeunit "NPR BCPT POS DS Voucher Issue" = X,
        codeunit "NPR BCPT POS DS Voucher Usage" = X,
        codeunit "NPR BCPT POS Framework: Mock" = X,
        codeunit "NPR BCPT POS Post GL Entries" = X,
        codeunit "NPR BCPT POS Post Item Entries" = X,
        codeunit "NPR BCPT POS Setup Event Subs" = X,
        codeunit "NPR BCPT Validate Voucher Subs" = X,
        codeunit "NPR BPCT Library - Random" = X,
        page "NPR APIV1InstalledApps" = X;
}