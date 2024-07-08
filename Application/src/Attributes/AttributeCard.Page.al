page 6014604 "NPR Attribute Card"
{
    Extensible = False;
    // NPR4.11/TSA/20150422  CASE 209946 - Entity and Shortcut Attributes
    // NPR5.35/ANEN/20170608 CASE 276486 Support for lookup from table
    // NPR5.39/BR  /20180215 CASE 295322 Added field Import File Column No.
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Client Attribute Card';
    ContextSensitiveHelpPage = 'docs/retail/attributes/how-to/client_attributes/client_attributes/';
    PageType = Card;
    SourceTable = "NPR Attribute";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the unique code that is used to identify a client attribute.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies additional information about this client attribute.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the name of the attribute.';
                    ApplicationArea = NPRRetail;
                }
                field("Code Caption"; Rec."Code Caption")
                {

                    ToolTip = 'Specifies the name which will be displayed on the page as a caption.';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Caption"; Rec."Filter Caption")
                {

                    ToolTip = 'Specifies the filter caption which will be displayed on the page.';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = '	Block the attribute if you don''t want it to be referenced.';
                    ApplicationArea = NPRRetail;
                }
                field(Global; Rec.Global)
                {

                    ToolTip = 'Specifies whether the attribute can be used globally.';
                    ApplicationArea = NPRRetail;
                }
                field("Value Datatype"; Rec."Value Datatype")
                {

                    ToolTip = 'Specifies the data format that the attribute will be displayed as (e.g. integer, Boolean).';
                    ApplicationArea = NPRRetail;
                }
                field("On Validate"; Rec."On Validate")
                {

                    ToolTip = 'The validation is used when there is a set of values that needs to be displayed, and if Value Datatype is set to Code. Otherwise, this field isn''t used. The selected or input data is validated against a set of values that can be in an existing table or predefined in the Client Attribute Value Lookup page.';
                    ApplicationArea = NPRRetail;
                }
                field("On Format"; Rec."On Format")
                {

                    ToolTip = 'Specifies the selected format. You can choose between Native, User''s Culture, and Custom.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table"; Rec."LookUp Table")
                {

                    ToolTip = 'The lookup table is enabled if we want to use the values from an existing table.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table Id"; Rec."LookUp Table Id")
                {

                    ToolTip = 'When we''re using an existing table for lookup values, we can define which one it will be by providing its ID.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Table Name"; Rec."LookUp Table Name")
                {

                    ToolTip = 'As there are multiple fields in a table, it''s necessary to identify which field will be used for client attributes by providing its ID.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Value Field Id"; Rec."LookUp Value Field Id")
                {

                    ToolTip = 'Specifies the description of the field that has been selected in Lookup Value Field ID.';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Value Field Name"; Rec."LookUp Value Field Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Value Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Description Field Id"; Rec."LookUp Description Field Id")
                {

                    ToolTip = 'Specifies the value of the LookUp Description Field Id field';
                    ApplicationArea = NPRRetail;
                }
                field("LookUp Description Field Name"; Rec."LookUp Description Field Name")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the LookUp Description Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Import File Column No."; Rec."Import File Column No.")
                {

                    ToolTip = 'Specifies the value of the Import File Column No. field';
                    ApplicationArea = NPRRetail;
                }
                group(HeyLoyaltyIntegration)
                {
                    Caption = 'HeyLoyalty Integration';

                    field("HeyLoyalty Field ID"; HeyLoyaltyFieldID)
                    {
                        Caption = 'HeyLoyalty Field ID';
                        ToolTip = 'Specifies the field id used to store the attribute values at HeyLoyalty.';
                        ApplicationArea = NPRHeyLoyalty;

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord();
                            HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo(Code), HeyLoyaltyFieldID, true);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Default HeyLoyalty Value"; DefaultHeyLoyaltyValue)
                    {
                        Caption = 'Default HeyLoyalty Value';
                        ToolTip = 'Specifies the default attribute value to be sent to HeyLoyalty in cases, when the attribute has no value assigned for the object in BC.';
                        ApplicationArea = NPRHeyLoyalty;

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord();
                            HLMappedValueMgt.SetMappedValue(Rec.RecordId(), 0, DefaultHeyLoyaltyValue, true);
                            CurrPage.Update(false);
                        end;
                    }
                    field("HL Auto Create New Values"; Rec."HL Auto Create New Values")
                    {
                        ToolTip = 'Specifies if new attribute values should be automatically created in BC for each non-existing attribute value received from HeyLoyalty.';
                        ApplicationArea = NPRHeyLoyalty;
                    }
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Attribute ID")
            {
                Caption = 'Attribute ID';
                Image = LinkWithExisting;
                RunObject = Page "NPR Attribute IDs";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code")
                              ORDER(Ascending);

                ToolTip = 'Executes the Attribute ID action';
                ApplicationArea = NPRRetail;
            }
            action(Translations)
            {
                Caption = 'Translations';
                Image = Translation;
                RunObject = Page "NPR Attribute Translations";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code", "Language ID");

                ToolTip = 'Executes the Translations action';
                ApplicationArea = NPRRetail;
            }
            action(Values)
            {
                Caption = 'Values';
                Image = List;
                RunObject = Page "NPR Attribute Value Lookup";
                RunPageLink = "Attribute Code" = FIELD(Code);
                RunPageView = SORTING("Attribute Code");

                ToolTip = 'Executes the Values action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        HeyLoyaltyFieldID := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Code), false);
        DefaultHeyLoyaltyValue := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), 0, false);
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        DefaultHeyLoyaltyValue: Text[100];
        HeyLoyaltyFieldID: Text[100];
}
