table 6060081 "NPR MCS Recomm. Model"
{
    Caption = 'MCS Recommendations Model';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MCS Recomm. Model Card";
    LookupPageID = "NPR MCS Recomm. Model List";

    fields
    {
        field(10; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MCSRecommendationsModel: Record "NPR MCS Recomm. Model";
            begin
                if Enabled and (not xRec.Enabled) then begin
                    MCSRecommendationsModel.SetRange(Enabled, true);
                    if MCSRecommendationsModel.Count >= 10 then begin
                        if GuiAllowed then
                            Message(TextMaxActiveReached);
                        Enabled := false;
                    end else
                        AskRefreshRecommendationsLines;
                end else begin
                    if (not Enabled) and xRec.Enabled then begin
                        DeleteRecommendationsLines;
                    end;
                end;
            end;
        }
        field(40; "Model ID"; Text[50])
        {
            Caption = 'Model ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Last Build ID"; BigInteger)
        {
            Caption = 'Last Build ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Last Build Date Time"; DateTime)
        {
            Caption = 'Last Build Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Last Item Ledger Entry No."; Integer)
        {
            Caption = 'Last Item Ledger Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Build Status"; Option)
        {
            Caption = 'Build Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Not Started,Running,Cancelling,Cancelled,Succeded,Failed';
            OptionMembers = NotStarted,Running,Cancelling,Cancelled,Succeded,Failed;
        }
        field(100; "Item View"; Text[250])
        {
            Caption = 'Item View';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupItemView;
            end;
        }
        field(110; "Attribute View"; Text[250])
        {
            Caption = 'Attribute View';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupAttributeView;
            end;
        }
        field(120; "Customer View"; Text[250])
        {
            Caption = 'Customer View';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupCustomerView;
            end;
        }
        field(130; "Item Ledger Entry View"; Text[250])
        {
            Caption = 'Item Ledger Entry View';
            DataClassification = CustomerContent;
        }
        field(200; Categories; Option)
        {
            Caption = 'Categories';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Category,Product Group,Item Category - Product Group,Item Group';
            OptionMembers = "Item Category","Product Group","Item Category - Product Group","Item Group";
        }
        field(210; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(220; "Last Catalog Export Date Time"; DateTime)
        {
            Caption = 'Last Catalog Export Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(230; "Last Usage Export Date Time"; DateTime)
        {
            Caption = 'Last Usage Export Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(240; "Catalog Uploaded"; Boolean)
        {
            Caption = 'Catalog Uploaded';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(250; "Usage Data Uploaded"; Boolean)
        {
            Caption = 'Usage Data Uploaded';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(300; "Recommendations per Seed"; Integer)
        {
            Caption = 'Recommendations per Seed';
            DataClassification = CustomerContent;
            InitValue = 5;
            MinValue = 1;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnModify()
    begin
        CheckCatalogChanges;
    end;

    trigger OnRename()
    begin
        Error(TextRenameNotAllowed);
    end;

    var
        TextMaxActiveReached: Label 'The maximum number of active models has been reached. Please deactivate a model before activating a new one.';
        TextRefreshRecommendationsLines: Label 'Do you want to refresh the Recommendations Lines for Recommendations Model %1 now? ';
        TextRenameNotAllowed: Label 'Renaming a Model is not allowed.';
        TextDeleteDisableNotAllowed: Label 'This Model cannot be disabled or deleted because it is set up as %1 in %2. ';

    local procedure LookupItemView()
    var
        Item: Record Item;
        RetailItemList: Page "Item List";
    begin
        if "Item View" <> '' then begin
            Item.SetView("Item View");
            RetailItemList.SetTableView(Item);
        end;
        RetailItemList.LookupMode := true;
        if RetailItemList.RunModal <> ACTION::LookupOK then
            exit;
        "Item View" := RetailItemList.NPR_GetViewText;
    end;

    local procedure LookupAttributeView()
    var
        NPRAttribute: Record "NPR Attribute";
        NPRAttributes: Page "NPR Attributes";
    begin
        if "Attribute View" <> '' then begin
            NPRAttribute.SetView("Attribute View");
            NPRAttributes.SetTableView(NPRAttribute);
        end;
        NPRAttributes.LookupMode := true;
        if NPRAttributes.RunModal <> ACTION::LookupOK then
            exit;
        "Attribute View" := NPRAttributes.GetViewText;
    end;

    local procedure LookupCustomerView()
    var
        Customer: Record Customer;
    begin
        if "Customer View" <> '' then begin
            Customer.SetView("Customer View");
        end;
        if Page.RunModal(0, Customer) <> ACTION::LookupOK then
            exit;

        "Customer View" := Customer.GetView();
    end;

    local procedure LookupItemLedgerEntryView()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemLedgerEntries: Page "Item Ledger Entries";
    begin
        if "Item Ledger Entry View" <> '' then begin
            ItemLedgerEntry.SetView("Item Ledger Entry View");
            ItemLedgerEntries.SetTableView(ItemLedgerEntry);
        end;
        ItemLedgerEntries.LookupMode := true;
        if ItemLedgerEntries.RunModal <> ACTION::LookupOK then
            exit;
    end;

    local procedure CheckCatalogChanges()
    begin
        if ("Item View" <> xRec."Item View") or
           ("Attribute View" <> xRec."Attribute View") or
           (Categories <> xRec.Categories) then
            "Last Catalog Export Date Time" := 0DT;
    end;

    local procedure CheckNotOnlineModel()
    var
        MCSRecommendationsSetup: Record "NPR MCS Recommendations Setup";
    begin
        MCSRecommendationsSetup.Get;
        if MCSRecommendationsSetup."Online Recommendations Model" = Code then
            Error(StrSubstNo(TextDeleteDisableNotAllowed, MCSRecommendationsSetup.FieldCaption(MCSRecommendationsSetup."Online Recommendations Model"), MCSRecommendationsSetup.TableCaption));
    end;

    local procedure AskRefreshRecommendationsLines()
    begin
        if GuiAllowed then
            if "Model ID" <> '' then
                if Confirm(StrSubstNo(TextRefreshRecommendationsLines, Format(Code))) then
                    RefreshRecommendationsLines;
    end;

    local procedure RefreshRecommendationsLines()
    var
        MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
    begin
        MCSRecommendationsHandler.RefreshRecommendations(Rec, GuiAllowed);
    end;

    local procedure DeleteRecommendationsLines()
    var
        MCSRecommendationsLine: Record "NPR MCS Recommendations Line";
    begin
        MCSRecommendationsLine.SetRange("Model No.", Code);
        MCSRecommendationsLine.DeleteAll(true);
    end;
}

