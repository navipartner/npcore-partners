page 6151172 "NpGp POS Sales Setup Card"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales

    Caption = 'Global POS Sales Setup Card';
    PageType = Card;
    SourceTable = "NpGp POS Sales Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code";Code)
                    {
                    }
                    field("Company Name";"Company Name")
                    {
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url";"Service Url")
                    {
                    }
                    field("Service Username";"Service Username")
                    {
                    }
                    field("Service Password";"Service Password")
                    {
                    }
                    field("Sync POS Sales Immediately";"Sync POS Sales Immediately")
                    {
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Global POS Sales Setup")
            {
                Caption = 'Validate Global POS Sales Setup';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpGpPOSSalesSyncMgt: Codeunit "NpGp POS Sales Sync Mgt.";
                begin
                    if NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
                      Message(Text001)
                    else
                      Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpGpPOSSalesSyncMgt: Codeunit "NpGp POS Sales Sync Mgt.";
    begin
        if not NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
          exit(Confirm(Text000,false));
    end;

    var
        Text000: Label 'Error in Global POS Sales Setup\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
}

