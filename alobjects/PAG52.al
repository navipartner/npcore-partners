pageextension 70000302 pageextension70000302 extends "Purchase Credit Memo" 
{
    // NPR4.18/TS/20151109  CASE 222241 Added Action Import From Text
    // NPR5.22/TJ/20160411 CASE 238601 Moved code from action Import From Scanner File to NPR Event Subscriber codeunit
    // NPR5.29/TJ/20170117 CASE 262797 Restored standard values for property TooltipML on some actions
    // NPR5.48/JDH /20181109 CASE 334163 Added Action caption
    actions
    {
        addfirst("F&unctions")
        {
            action("Import From Scanner File")
            {
                Caption = 'Import From Scanner File';
                Image = Import;
                Promoted = true;
            }
        }
    }
}

