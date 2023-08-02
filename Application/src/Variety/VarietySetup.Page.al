page 6059970 "NPR Variety Setup"
{
    Extensible = False;
    Caption = 'Variety Setup';
    ContextSensitiveHelpPage = 'docs/retail/varieties/how-to/create_variety/';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,View,Update';
    SourceTable = "NPR Variety Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Variety Enabled"; Rec."Variety Enabled")
                {
                    ToolTip = 'Enable the variety.';
                    ApplicationArea = NPRRetail;
                }
#IF (BC17 or BC18 or BC19 or BC20)                 
                field("Item Journal Blocking"; Rec."Item Journal Blocking")
                {
                    ToolTip = 'Specifies if the items without variants are allowed.';
                    ApplicationArea = NPRRetail;
                }
#ENDIF
                field("Variant Description"; Rec."Variant Description")
                {
                    ToolTip = 'Specifies the first variant description';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Description 2"; Rec."Variant Description 2")
                {
                    ToolTip = 'Specifies the second variant description.';
                    ApplicationArea = NPRRetail;
                }
                field("Create Variant Code From"; Rec."Create Variant Code From")
                {
                    ToolTip = 'Specifies the subscriber codeunit that can create variant codes';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Descriptions"; Rec."Custom Descriptions")
                {
                    ToolTip = 'If variant is selected on sales and purchase line item description is copied into description on sales line, purchase line, POS sales line, and variant description is copied into description 2 on sales line, purchase line and POS sales line.';
                    ApplicationArea = NPRRetail;
                }
                field("Pop up Variety Matrix"; Rec."Pop up Variety Matrix")
                {
                    ToolTip = 'Specifies if variety matrix will pop up on documents when item with variants is selected.';
                    ApplicationArea = NPRRetail;
                }
                field("Pop up on Sales Order"; Rec."Pop up on Sales Order")
                {
                    ToolTip = 'Specifies if a variety matrix will be shown on Sales Order';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Pop up on Sales Return Order"; Rec."Pop up on Sales Return Order")
                {
                    ToolTip = 'Specifies if a variety matrix will be shown on Sales Return Order';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Pop up on Purchase Order"; Rec."Pop up on Purchase Order")
                {
                    ToolTip = 'Specifies if a variety matrix will be shown on Purchase Order';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Pop up on Purch. Return Order"; Rec."Pop up on Purch. Return Order")
                {
                    ToolTip = 'Specifies if a variety matrix will be shown on Purchase Return Order';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Pop up on Transfer Order"; Rec."Pop up on Transfer Order")
                {
                    ToolTip = 'Specifies if a variety matrix will be shown on Transfer Order';
                    ApplicationArea = NPRRetail;
                    Importance = Additional;
                }
                field("Variant No. Series"; Rec."Variant No. Series")
                {
                    ToolTip = 'Specifies the value of the Variant Std. No. Serie field. Number series must be maximum 10 characters long.';
                    ApplicationArea = NPRRetail;
                }
                field("Activate Inventory"; Rec."Activate Inventory")
                {
                    ToolTip = 'Activate Inventory in Variety Lookup on POS ';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Barcode (Item Cross Ref.)")
            {
                Caption = 'Barcode (Item Ref.)';
                field("Create Item Cross Ref. auto."; Rec."Create Item Cross Ref. auto.")
                {
                    ToolTip = 'Specifies if the item cross references should be created automatically or not';
                    ApplicationArea = NPRRetail;
                }
                field("Barcode Type (Item Cross Ref.)"; Rec."Barcode Type (Item Cross Ref.)")
                {
                    Editable = Rec."Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the barcode type for the item cross reference';
                    ApplicationArea = NPRRetail;
                }
                field("Internal EAN No. Series"; Rec."Internal EAN No. Series")
                {
                    ToolTip = 'Specifies the number series used for the internal EAN number.';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("External EAN No. Series"; Rec."External EAN No. Series")
                {
                    ToolTip = 'Specifies the value of the External EAN No. Series field';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("EAN-Internal"; Rec."EAN-Internal")
                {
                    ToolTip = 'Specifies the length of the EAN-Internal number';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field("EAN-External"; Rec."EAN-External")
                {
                    ToolTip = 'Specifies the length of the EAN-External number';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                group(ItemReferences)
                {
                    Caption = 'Item References';
                    field("Item Cross Ref. No. Series (I)"; Rec."Item Cross Ref. No. Series (I)")
                    {
                        Caption = 'No. Series';
                        Editable = Rec."Create Item Cross Ref. auto.";
                        ToolTip = 'If value is set, then item reference with type Bar Code will be created for Item. For details, please check an actions on Item Card - Add Missing Barcode(s).';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            if Rec."Item Cross Ref. No. Series (V)" = '' then
                                Rec."Item Cross Ref. No. Series (V)" := Rec."Item Cross Ref. No. Series (I)";
                        end;
                    }
                    field("Item Cross Ref. Description(I)"; Rec."Item Cross Ref. Description(I)")
                    {
                        Caption = 'Description';
                        ToolTip = 'Specifies the way item reference description is filled in, when item reference is created for an item.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Ref. Description 2 (I)"; Rec."Item Ref. Description 2 (I)")
                    {
                        Caption = 'Description 2';
                        ToolTip = 'Specifies the way item reference description 2 is filled in, when item reference is created for an item.';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(ItemVariantReferences)
                {
                    Caption = 'Item Variant References';
                    field("Item Cross Ref. No. Series (V)"; Rec."Item Cross Ref. No. Series (V)")
                    {
                        Caption = 'No. Series';
                        Editable = Rec."Create Item Cross Ref. auto.";
                        ToolTip = 'If value is set, then item reference with type Bar Code will be created for each Item Variant. For details, please check an actions on Item Card - Add Missing Barcode(s).';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Cross Ref. Description(V)"; Rec."Item Cross Ref. Description(V)")
                    {
                        Caption = 'Description';
                        ToolTip = 'Specifies the way item reference description is filled in, when item reference is created for an item variant.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Item Ref. Description 2 (V)"; Rec."Item Ref. Description 2 (V)")
                    {
                        Caption = 'Description 2';
                        ToolTip = 'Specifies the way item reference description 2 is filled in, when item reference is created for an item variant.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(View)
            {
                Caption = 'View';
                field("Hide Inactive Values"; Rec."Hide Inactive Values")
                {
                    ToolTip = 'Whether Inactive Values should be hidden in the Variant Matrix by default';
                    ApplicationArea = NPRRetail;
                }
                field("Show Column Names"; Rec."Show Column Names")
                {
                    ToolTip = 'Specifies whether you want variety value names to be used as column names in the Variant Matrix by default. If disabled, variety value codes will be used as column names in the matrix.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Create Barcode No. Series")
            {
                Caption = 'Create Barcode No. Series';
                action("EAN13 Internal")
                {
                    Caption = 'EAN13 Internal';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;

                    ToolTip = 'Create a new number series for EAN13 Internal.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.CreateEAN13BarcodeNoSeries(true);
                    end;
                }
                action("EAN13 External")
                {
                    Caption = 'EAN13 External';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;

                    ToolTip = 'Create a new number series for EAN13 External.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.CreateEAN13BarcodeNoSeries(false);
                    end;
                }
            }
            group("Copy Barcode Setup")
            {
                Caption = 'Copy Barcode Setup';
                action("Show Original Setup")
                {
                    Caption = 'Show Original Setup';
                    Image = History;
                    ToolTip = 'Display the original setup for the EAN number series.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VRTCloneData.ShowEAN13BarcodeNoSetup();
                    end;
                }
                action("Item Reference")
                {
                    Caption = 'Item Reference';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Reference Entries";
                    RunPageView = SORTING("Reference Type", "Reference No.");
                    ToolTip = 'Displays the item reference entries';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Update")
            {
                Caption = 'Update';
                action("Item Variant Descriptions")
                {
                    Caption = 'Item Variant Descriptions';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Update all item variant descriptions with the values from the variety setup.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VrtCloneData.UpdateVariantDescriptions();
                    end;
                }
                action("Item Reference Descriptions")
                {
                    Caption = 'Item Reference Descriptions';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ToolTip = 'Updates fields Description and Description 2 for all item references according to current variety setup.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        VrtCloneData.UpdateItemRefDescription();
                    end;
                }
                action(Barcodes)
                {
                    Caption = 'Barcodes';
                    Image = BarCode;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Report "NPR Update Barcodes";
                    ToolTip = 'Update all item barcodes with the values from the variety setup.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(processing)
        {
            group("&Setup")
            {
                Caption = '&Setup';
                Image = Setup;
                action(Variety)
                {
                    Caption = 'Variety';
                    Image = ChangeLog;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety";
                    ToolTip = 'Display the Variety page in which all varieties are listed. You can create new varieties if needed.';
                    ApplicationArea = NPRRetail;
                }
                action("Field Setup")
                {
                    Caption = 'Field Setup';
                    Image = Column;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Fields Setup";
                    ToolTip = 'Display the Variety Field Setup page in which all field setups for varieties are listed. You can create new field setups for varieties.';
                    ApplicationArea = NPRRetail;
                }
                action(Groups)
                {
                    Caption = 'Groups';
                    Image = Allocations;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Group";
                    ToolTip = 'Display the Variety Group page in which all variety groups are listed. You can create new variety groups.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Wizard)
            {
                action("Setup Wizard")
                {
                    Caption = 'Setup Wizard';
                    Image = Setup;

                    ToolTip = 'Execute the Setup Wizard for the variety creation.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        VarietySetupWizard: Codeunit "NPR Variety Setup Wizard";
                    begin
                        VarietySetupWizard.Run();
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

