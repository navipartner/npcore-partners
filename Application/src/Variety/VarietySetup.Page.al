page 6059970 "NPR Variety Setup"
{
    // VRT1.11/MHA/20160412  CASE 236840 Added field 40 Hide Inactive Variants
    // VRT1.11/JDH /20160602 CASE 242940 Added multible new fields for Description and Barcode creation mainly
    // NPR5.27/MMV /20161021 CASE 254486 Added actions for new convert reports.
    // NPR5.33/JDH /20170623 CASE 281812 Added Pages Variety, Variety Groups and Variety Field setup to action ribbon
    // NPR5.36/JDH /20170922 CASE 288696 Setup Wizard created
    // NPR5.43/JDH /20180628 CASE 317108 Added "Create Variant Code From"

    Caption = 'Variety Setup';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,View,Update';
    SourceTable = "NPR Variety Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Variety Enabled"; "Variety Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variety Enabled field';
                }
                field("Item Journal Blocking"; "Item Journal Blocking")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Journal Blocking field';
                }
                field("Variant Description"; "Variant Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description field';
                }
                field("Variant Description 2"; "Variant Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Description 2 field';
                }
                field("Create Variant Code From"; "Create Variant Code From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Variant Code From field';
                }
            }
            group("Barcode (Alternative No.)")
            {
                Caption = 'Barcode (Alternative No.)';
                field("Create Alt. No. automatic"; "Create Alt. No. automatic")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Alt. No. automatic field';
                }
                field("Barcode Type (Alt. No.)"; "Barcode Type (Alt. No.)")
                {
                    ApplicationArea = All;
                    Editable = "Create Alt. No. automatic";
                    ToolTip = 'Specifies the value of the Barcode Type (Alt. No.) field';
                }
                field("Alt. No. No. Series (I)"; "Alt. No. No. Series (I)")
                {
                    ApplicationArea = All;
                    Editable = "Create Alt. No. automatic";
                    ToolTip = 'Specifies the value of the Alt. No. No. Series (Item) field';

                    trigger OnValidate()
                    begin
                        //-NPR5.33 [242105]
                        if "Alt. No. No. Series (V)" = '' then
                            "Alt. No. No. Series (V)" := "Alt. No. No. Series (I)";
                        //+NPR5.33 [242105]
                    end;
                }
                field("Alt. No. No. Series (V)"; "Alt. No. No. Series (V)")
                {
                    ApplicationArea = All;
                    Editable = "Create Alt. No. automatic";
                    ToolTip = 'Specifies the value of the Alt. No. No. Series (Variant) field';
                }
            }
            group("Barcode (Item Cross Ref.)")
            {
                Caption = 'Barcode (Item Cross Ref.)';
                field("Create Item Cross Ref. auto."; "Create Item Cross Ref. auto.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create Item Cross Ref. auto. field';
                }
                field("Barcode Type (Item Cross Ref.)"; "Barcode Type (Item Cross Ref.)")
                {
                    ApplicationArea = All;
                    Editable = "Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Barcode Type (Item Cross Ref.) field';
                }
                field("Item Cross Ref. No. Series (I)"; "Item Cross Ref. No. Series (I)")
                {
                    ApplicationArea = All;
                    Editable = "Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Item Cross Ref. No. Series (Item) field';

                    trigger OnValidate()
                    begin
                        //-NPR5.33 [242105]
                        if "Item Cross Ref. No. Series (V)" = '' then
                            "Item Cross Ref. No. Series (V)" := "Item Cross Ref. No. Series (I)";
                        //+NPR5.33 [242105]
                    end;
                }
                field("Item Cross Ref. No. Series (V)"; "Item Cross Ref. No. Series (V)")
                {
                    ApplicationArea = All;
                    Editable = "Create Item Cross Ref. auto.";
                    ToolTip = 'Specifies the value of the Item Cross Ref. No. Series (Variant) field';
                }
                field("Item Cross Ref. Description(I)"; "Item Cross Ref. Description(I)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Item) field';
                }
                field("Item Cross Ref. Description(V)"; "Item Cross Ref. Description(V)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Cross Ref. Description (Variant) field';
                }
            }
            group(View)
            {
                Caption = 'View';
                field("Hide Inactive Values"; "Hide Inactive Values")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether Inactive Values should be hidden in the Variant Matrix by default';
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
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the EAN13 Internal action';

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
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the EAN13 External action';

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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Show Original Setup action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        //-VRT1.11
                        VRTCloneData.ShowEAN13BarcodeNoSetup;
                        //+VRT1.11
                    end;
                }
                action("Disable Original Setup")
                {
                    Caption = 'Disable Original Setup';
                    Image = InactivityDescription;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Disable Original Setup action';

                    trigger OnAction()
                    var
                        VRTCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        //-VRT1.11
                        VRTCloneData.DisableOldBarcodeSetup;
                        //+VRT1.11
                    end;
                }
                action("Alternative No.")
                {
                    Caption = 'Alternative No.';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR Alternative Number";
                    RunPageView = SORTING("Alt. No.", Type);
                    ApplicationArea = All;
                    ToolTip = 'Executes the Alternative No. action';
                }
                action("Item Cross Reference")
                {
                    Caption = 'Item Cross Reference';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Cross Reference Entries";
                    RunPageView = SORTING("Cross-Reference Type", "Cross-Reference No.");
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Cross Reference action';
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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Variant Descriptions action';

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        //-VRT1.11
                        VrtCloneData.UpdateVariantDescriptions;
                        //+VRT1.11
                    end;
                }
                action("Item Cross Reference Descriptions")
                {
                    Caption = 'Item Cross Reference Descriptions';
                    Image = UpdateDescription;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Cross Reference Descriptions action';

                    trigger OnAction()
                    var
                        VrtCloneData: Codeunit "NPR Variety Clone Data";
                    begin
                        //-VRT1.11
                        VrtCloneData.UpdateItemCrossRefDescription;
                        //+VRT1.11
                    end;
                }
                action(Barcodes)
                {
                    Caption = 'Barcodes';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Report "NPR Update Barcodes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Barcodes action';
                }
            }
            group(Convert)
            {
                Caption = 'Convert';
                action("Alt. No. to Item Cross Reference")
                {
                    Caption = 'Alt. No. to Item Cross Reference';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Report "NPR Alt. No. to ICR barcodes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Alt. No. to Item Cross Reference action';
                }
                action("Item Cross Reference to Alt. No.")
                {
                    Caption = 'Item Cross Reference to Alt. No.';
                    Image = BarCode;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    RunObject = Report "NPR ICR to Alt. No. barcodes";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Item Cross Reference to Alt. No. action';
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
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Variety action';
                }
                action("Field Setup")
                {
                    Caption = 'Field Setup';
                    Image = Column;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Fields Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Field Setup action';
                }
                action(Groups)
                {
                    Caption = 'Groups';
                    Image = Allocations;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "NPR Variety Group";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Groups action';
                }
            }
            group(Wizard)
            {
                action("Setup Wizard")
                {
                    Caption = 'Setup Wizard';
                    Image = Setup;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Setup Wizard action';

                    trigger OnAction()
                    var
                        VarietySetupWizard: Codeunit "NPR Variety Setup Wizard";
                    begin
                        //-NPR5.36 [288696]
                        VarietySetupWizard.Run;
                        //+NPR5.36 [288696]
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}

