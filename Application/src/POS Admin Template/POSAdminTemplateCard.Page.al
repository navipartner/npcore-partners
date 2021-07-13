page 6150740 "NPR POS Admin. Template Card"
{
    // NPR5.51/VB  /20190719  CASE 352582 POS Administrative Templates feature

    Caption = 'POS Administrative Template Card';
    DataCaptionExpression = GetName();
    DataCaptionFields = Id, Name;
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR POS Admin. Template";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Id; Rec.Id)
                {

                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Persist on Client"; Rec."Persist on Client")
                {

                    ToolTip = 'Specifies the value of the Persist on Client field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(MainMenu)
            {
                Caption = 'Main Menu';
                field("Role Center"; Rec."Role Center")
                {

                    ToolTip = 'Specifies the value of the Role Center field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Role Center Password"; Rec."Role Center Password")
                {

                    Editable = RoleCenterPasswordEditable;
                    ToolTip = 'Specifies the value of the Role Center Password field';
                    ApplicationArea = NPRRetail;
                }
                field(Configuration; Rec.Configuration)
                {

                    ToolTip = 'Specifies the value of the Configuration field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetControlStatuses();
                    end;
                }
                field("Configuration Password"; Rec."Configuration Password")
                {

                    Editable = ConfigurationPasswordEditable;
                    ToolTip = 'Specifies the value of the Configuration Password field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Scopes)
            {
                Caption = 'Scopes';
                Image = UserInterface;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR POS Admin. Template Scopes";
                RunPageLink = "POS Admin. Template Id" = FIELD(Id);

                ToolTip = 'Executes the Scopes action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetControlStatuses();
    end;

    var
        Text001: Label 'Unnamed template (%1)';
        RoleCenterPasswordEditable: Boolean;
        ConfigurationPasswordEditable: Boolean;

    local procedure GetName(): Text
    begin
        if Rec.Name <> '' then
            exit(Rec.Name)
        else
            exit(StrSubstNo(Text001, Rec.Id));
    end;

    local procedure SetControlStatuses()
    begin
        RoleCenterPasswordEditable := Rec."Role Center" = Rec."Role Center"::Password;
        ConfigurationPasswordEditable := Rec.Configuration = Rec.Configuration::Password;
    end;
}

