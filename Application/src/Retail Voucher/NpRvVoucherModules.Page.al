page 6151011 "NPR NpRv Voucher Modules"
{
    Caption = 'Retail Voucher Modules';
    PageType = List;
    SourceTable = "NPR NpRv Voucher Module";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Event Codeunit ID"; "Event Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit ID field';
                }
                field("Event Codeunit Name"; "Event Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Codeunit Name field';
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

