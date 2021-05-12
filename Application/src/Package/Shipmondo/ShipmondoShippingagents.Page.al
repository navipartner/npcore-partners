page 6014569 "NPR Package Shipping Agents"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    CardPageID = "NPR Package Shipping agent";
    PageType = List;
    SourceTable = "NPR Package Shipping Agent";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Ship to Contact Mandatory"; Rec."Ship to Contact Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship to Contact Mandatory field';
                }
                field("Automatic Drop Point Service"; Rec."Automatic Drop Point Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Automatic Drop Point Service field';
                }
                field("Email Mandatory"; "Email Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the E-mail is mandatory';
                }
                field("Phone Mandatory"; "Phone Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Phone Number is mandatory';
                }
                field("Use own Agreement"; Rec."Use own Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use own Agreement field';
                }
                field("Package Type Required"; Rec."Package Type Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Package Type Required field';
                }

            }
        }
    }

}

