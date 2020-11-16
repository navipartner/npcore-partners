page 6014671 "NPR Lookup Templates"
{
    // NPR5.20/VB/20160310 CASE 236519 Added support for configurable lookup templates.
    // NPR5.22/VB/20160330 CASE 238802 Preemptive push field.
    // NPR5.22/VB/20160414 CASE 238802 Added support for sorting order.
    // NPR5.32.10/MMV /20170308 CASE 265454 Changed export manifest action.
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.

    Caption = 'Lookup Templates';
    PageType = List;
    SourceTable = "NPR Lookup Template";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                }
                field(Class; Class)
                {
                    ApplicationArea = All;
                }
                field("Value Field No."; "Value Field No.")
                {
                    ApplicationArea = All;
                }
                field("Preemptive Push"; "Preemptive Push")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Value Field Name"; "Value Field Name")
                {
                    ApplicationArea = All;
                }
                field("Sort By Field No."; "Sort By Field No.")
                {
                    ApplicationArea = All;
                }
                field("Sorting Order"; "Sorting Order")
                {
                    ApplicationArea = All;
                }
                field("Has Lines"; "Has Lines")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Fields)
            {
                Caption = 'Fields';
                Image = Splitlines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Lookup Template Lines";
                RunPageLink = "Lookup Template Table No." = FIELD("Table No.");
                ApplicationArea = All;
            }
            action("Export Managed Dependency Manifest")
            {
                Caption = 'Export Managed Dependency Manifest';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ManagedDepMgt: Codeunit "NPR Managed Dependency Mgt.";
                    Rec2: Record "NPR Lookup Template";
                    JArray: DotNet JArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);
                    //-NPR5.32.10 [265454]
                    JArray := JArray.JArray();
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                    //ManagedDepMgt.ExportManifest(Rec2);
                    //+NPR5.32.10 [265454]
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InitTemplates();
    end;

    local procedure InitTemplates()
    var
        LookupTemplate: Record "NPR Lookup Template";
        LookupTemplateLine: Record "NPR Lookup Template Line";
    begin
        InitTemplateCustomer();
        InitTemplateItem();
        InitTemplateRetailList();
    end;

    local procedure InitTemplateCustomer()
    var
        LookupTemplate: Record "NPR Lookup Template";
        LookupTemplateLine: Record "NPR Lookup Template Line";
    begin
        if LookupTemplate.Get(DATABASE::Customer) then
            exit;

        LookupTemplateLine.SetRange("Lookup Template Table No.", DATABASE::Customer);
        if LookupTemplateLine.FindFirst then
            exit;

        LookupTemplate.Init;
        LookupTemplate."Table No." := DATABASE::Customer;
        LookupTemplate.Class := 'customer';
        LookupTemplate."Value Field No." := 1;
        LookupTemplate.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 1;
        LookupTemplateLine.Class := 'no';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 1;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(15% - 2px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 2;
        LookupTemplateLine."Field No." := 5;
        LookupTemplateLine.Class := 'address';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 5;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(40% - 3px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 3;
        LookupTemplateLine."Field No." := 9;
        LookupTemplateLine.Class := 'phone';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 9;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(25% - 3px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 4;
        LookupTemplateLine."Field No." := 58;
        LookupTemplateLine.Class := 'balance';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 58;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Right;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(20% - 2px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::Number;
        LookupTemplateLine.Searchable := false;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 2;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 2;
        LookupTemplateLine.Class := 'name';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Text;
        LookupTemplateLine."Caption Text" := '';
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 0;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 32;
        LookupTemplateLine."Width (CSS)" := '60%';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Customer;
        LookupTemplateLine."Row No." := 2;
        LookupTemplateLine."Col No." := 2;
        LookupTemplateLine."Field No." := 7;
        LookupTemplateLine.Class := 'city';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Text" := '';
        LookupTemplateLine."Caption Table No." := DATABASE::Customer;
        LookupTemplateLine."Caption Field No." := 7;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 24;
        LookupTemplateLine."Width (CSS)" := 'calc(40% - 6px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::Number;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);
    end;

    local procedure InitTemplateItem()
    var
        LookupTemplate: Record "NPR Lookup Template";
        LookupTemplateLine: Record "NPR Lookup Template Line";
    begin
        if LookupTemplate.Get(DATABASE::Item) then
            exit;

        LookupTemplateLine.SetRange("Lookup Template Table No.", DATABASE::Item);
        if LookupTemplateLine.FindFirst then
            exit;

        LookupTemplate.Init;
        LookupTemplate."Table No." := DATABASE::Item;
        LookupTemplate.Class := 'item';
        LookupTemplate."Value Field No." := 1;
        LookupTemplate.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 1;
        LookupTemplateLine.Class := 'no';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Item;
        LookupTemplateLine."Caption Field No." := 1;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(25% - 2px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 2;
        LookupTemplateLine."Field No." := 6014400;
        LookupTemplateLine.Class := 'category';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Table;
        LookupTemplateLine."Caption Table No." := DATABASE::"NPR Item Group";
        LookupTemplateLine."Caption Field No." := 0;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(25% - 3px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine."Related Table No." := DATABASE::"NPR Item Group";
        LookupTemplateLine."Related Field No." := 2;
        LookupTemplateLine.Searchable := false;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 3;
        LookupTemplateLine."Field No." := 31;
        LookupTemplateLine.Class := 'vendor';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Table;
        LookupTemplateLine."Caption Table No." := DATABASE::Vendor;
        LookupTemplateLine."Caption Field No." := 0;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(25% - 3px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine."Related Table No." := DATABASE::Vendor;
        LookupTemplateLine."Related Field No." := 2;
        LookupTemplateLine.Searchable := false;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 4;
        LookupTemplateLine."Field No." := 68;
        LookupTemplateLine.Class := 'inventory';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::Item;
        LookupTemplateLine."Caption Field No." := 68;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Right;
        LookupTemplateLine."Font Size (pt)" := 16;
        LookupTemplateLine."Width (CSS)" := 'calc(25% - 2px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::Number;
        LookupTemplateLine.Searchable := false;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 2;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 3;
        LookupTemplateLine.Class := 'description';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Text;
        LookupTemplateLine."Caption Text" := '';
        LookupTemplateLine."Caption Table No." := DATABASE::Item;
        LookupTemplateLine."Caption Field No." := 0;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 32;
        LookupTemplateLine."Width (CSS)" := '80%';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::Item;
        LookupTemplateLine."Row No." := 2;
        LookupTemplateLine."Col No." := 2;
        LookupTemplateLine."Field No." := 18;
        LookupTemplateLine.Class := 'price';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Text" := '';
        LookupTemplateLine."Caption Table No." := DATABASE::Item;
        LookupTemplateLine."Caption Field No." := 18;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Right;
        LookupTemplateLine."Font Size (pt)" := 24;
        LookupTemplateLine."Width (CSS)" := 'calc(20% - 6px)';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::Number;
        LookupTemplateLine.Searchable := false;
        LookupTemplateLine.Insert(true);
    end;

    local procedure InitTemplateRetailList()
    var
        LookupTemplate: Record "NPR Lookup Template";
        LookupTemplateLine: Record "NPR Lookup Template Line";
    begin
        if LookupTemplate.Get(DATABASE::"NPR Retail List") then
            exit;

        LookupTemplateLine.SetRange("Lookup Template Table No.", DATABASE::"NPR Retail List");
        if LookupTemplateLine.FindFirst then
            exit;

        LookupTemplate.Init;
        LookupTemplate."Table No." := DATABASE::"NPR Retail List";
        LookupTemplate.Class := 'retail-list';
        LookupTemplate."Value Field No." := 10;
        LookupTemplate.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::"NPR Retail List";
        LookupTemplateLine."Row No." := 1;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 10;
        LookupTemplateLine.Class := 'code';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Field;
        LookupTemplateLine."Caption Table No." := DATABASE::"NPR Sale Line POS";
        LookupTemplateLine."Caption Field No." := 102;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 12;
        LookupTemplateLine."Width (CSS)" := '';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);

        LookupTemplateLine.Init;
        LookupTemplateLine."Lookup Template Table No." := DATABASE::"NPR Retail List";
        LookupTemplateLine."Row No." := 2;
        LookupTemplateLine."Col No." := 1;
        LookupTemplateLine."Field No." := 2;
        LookupTemplateLine.Class := 'caption';
        LookupTemplateLine."Caption Type" := LookupTemplateLine."Caption Type"::Text;
        LookupTemplateLine."Caption Text" := '';
        LookupTemplateLine."Caption Table No." := DATABASE::"NPR Retail List";
        LookupTemplateLine."Caption Field No." := 0;
        LookupTemplateLine."Text Align" := LookupTemplateLine."Text Align"::Left;
        LookupTemplateLine."Font Size (pt)" := 32;
        LookupTemplateLine."Width (CSS)" := '';
        LookupTemplateLine."Number Format" := LookupTemplateLine."Number Format"::None;
        LookupTemplateLine.Searchable := true;
        LookupTemplateLine.Insert(true);
    end;
}

