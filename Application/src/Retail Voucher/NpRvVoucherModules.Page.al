page 6151011 "NPR NpRv Voucher Modules"
{
    Extensible = False;
    Caption = 'Retail Voucher Modules';
    PageType = List;
    SourceTable = "NPR NpRv Voucher Module";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit ID"; Rec."Event Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Event Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit Name"; Rec."Event Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Event Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpRvModuleMgt: Codeunit "NPR NpRv Module Mgt.";
    begin
        NpRvModuleMgt.OnInitVoucherModules(Rec);
    end;
}

