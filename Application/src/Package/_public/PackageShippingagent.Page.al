page 6014568 "NPR Package Shipping agent"
{
    Extensible = true;

    PageType = Card;
    SourceTable = "NPR package Shipping Agent";
    caption = 'NPR Shipping Agent';
    UsageCategory = None;

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
                field("Shipping Provider Product Code"; Rec."Shipping Provider Code")
                {

                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipping Provider Code field.';
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
                field("Return shipping Agent Code"; Rec."Return shipping Agent Code")
                {
                    ToolTip = 'Return shipping Agent Code';
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
                field("LxWxH Dimensions Required"; Rec."LxWxH Dimensions Required")
                {
                    ToolTip = 'Specifies the value of the Length_Width_Height Dimensions Required field.';
                    ApplicationArea = NPRRetail;
                }
                field("running_metre required"; Rec."running_metre required")
                {
                    ToolTip = 'Specifies the value of the running_metre field.';
                    ApplicationArea = NPRRetail;
                }
                field("Volume Required"; Rec."Volume Required")
                {
                    ToolTip = 'Specifies the value of the  Volume cubic metres  field.';
                    ApplicationArea = NPRRetail;
                }
                field("Declared Value Required"; Rec."Declared Value Required")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Declared Value Required field.';
                }
                field("Declared Max Amount Value"; Rec."Declared Max Amount Value")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Declared Max Amount Value field.';
                }
                field("Declared Value Currency Code"; Rec."Declared Value Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Declared Value Currency Code field.';
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

