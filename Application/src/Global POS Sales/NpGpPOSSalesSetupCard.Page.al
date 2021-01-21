page 6151172 "NPR NpGp POS Sales Setup Card"
{
    Caption = 'Global POS Sales Setup Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpGp POS Sales Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field("Company Name"; "Company Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Company Name field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Url field';
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Username field';
                    }
                    field(Password; Password)
                    {
                        ApplicationArea = All;
                        Caption = 'Service Password';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Service Password field';

                        trigger OnValidate()
                        begin
                            //-NPR5.51 [337539]
                            HandlePassword(Password);
                            //+NPR5.51 [337539]
                        end;
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Validate Global POS Sales Setup action';

                trigger OnAction()
                var
                    NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
                begin
                    if NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if not IsNullGuid("Service Password") then begin
            IsolatedStorage.Get("Service Password", DataScope::Company, Password);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
    begin
        if not NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        Text000: Label 'Error in Global POS Sales Setup\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
        Password: Text;
}

