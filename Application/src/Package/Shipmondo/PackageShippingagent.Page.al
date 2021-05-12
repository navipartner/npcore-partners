page 6014568 "NPR Package Shipping agent"
{

    PageType = Card;
    SourceTable = "NPR package Shipping Agent";
    caption = 'NPR Shipping Agent';
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Shipping Agent Code ';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Shipping Agent Code Name';
                }
                group(Control6014412)
                {

                }
                field("Use own Agreement"; Rec."Use own Agreement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Shipping has an agreement with the Provider ';

                }
                field("Ship to Contact Mandatory"; Rec."Ship to Contact Mandatory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the "Ship to Contact" is mandatory';

                }
                field("Automatic Drop Point Service"; Rec."Automatic Drop Point Service")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the "Automatic Drop Point" Service is mandatory';
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
                group(Advanced)
                {
                    Caption = 'Advanced';

                }
                field("Package Type Required"; Rec."Package Type Required")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the "Package Type" Service is required';
                    trigger OnValidate();
                    begin
                        PackageRequired := Rec."Package Type Required";
                    end;
                }
            }
            part("NPR Services Combination"; "NPR Services Combination")
            {
                ApplicationArea = All;
                SubPageLink = "Shipping Agent" = FIELD(Code);
            }
            part("NPR Pacsoft Package Codes"; "NPR Package Codes")
            {
                ApplicationArea = All;
                SubPageLink = "Shipping Agent Code" = FIELD(Code);
                Visible = PackageRequired;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord();
    begin
        PackageRequired := Rec."Package Type Required";
    end;

    var
        PackageRequired: Boolean;
}

