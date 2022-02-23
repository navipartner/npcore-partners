page 6014568 "NPR Package Shipping agent"
{
    Extensible = true;

    PageType = Card;
    SourceTable = "NPR package Shipping Agent";
    caption = 'NPR Shipping Agent';
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies Shipping Agent Code ';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies Shipping Agent Code Name';
                    ApplicationArea = NPRRetail;
                }
                group(Control6014412)
                {

                }
                field("Use own Agreement"; Rec."Use own Agreement")
                {

                    ToolTip = 'Specifies if the Shipping has an agreement with the Provider ';
                    ApplicationArea = NPRRetail;

                }
                field("Ship to Contact Mandatory"; Rec."Ship to Contact Mandatory")
                {

                    ToolTip = 'Specifies if the "Ship to Contact" is mandatory';
                    ApplicationArea = NPRRetail;

                }
                field("Automatic Drop Point Service"; Rec."Automatic Drop Point Service")
                {

                    ToolTip = 'Specifies if the "Automatic Drop Point" Service is mandatory';
                    ApplicationArea = NPRRetail;
                }
                field("Email Mandatory"; Rec."Email Mandatory")
                {

                    ToolTip = 'Specifies if the E-mail is mandatory';
                    ApplicationArea = NPRRetail;
                }
                field("Phone Mandatory"; Rec."Phone Mandatory")
                {

                    ToolTip = 'Specifies if the Phone Number is mandatory';
                    ApplicationArea = NPRRetail;
                }
                group(Advanced)
                {
                    Caption = 'Advanced';

                }
                field("Package Type Required"; Rec."Package Type Required")
                {

                    ToolTip = 'Specifies if the "Package Type" Service is required';
                    ApplicationArea = NPRRetail;
                    trigger OnValidate();
                    begin
                        PackageRequired := Rec."Package Type Required";
                    end;
                }
            }
            part("NPR Services Combination"; "NPR Services Combination")
            {

                SubPageLink = "Shipping Agent" = FIELD(Code);
                ApplicationArea = NPRRetail;
            }
            part("NPR Pacsoft Package Codes"; "NPR Package Codes")
            {

                SubPageLink = "Shipping Agent Code" = FIELD(Code);
                Visible = PackageRequired;
                ApplicationArea = NPRRetail;
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

