page 6014656 "Proxy Assemblies"
{
    // NPR4.15/VB/20150904 CASE 219606 Proxy utility for handling hardware communication
    // NPR5.00/NPKNAV/20160113  CASE 219606 NP Retail 2016
    // NPR5.01/VB/20160222 CASE 234462 Export Manifest file to managed services
    // NPR5.32.10/MMV /20170308 CASE 265454 Changed export manifest action.
    // NPR5.32.10/MMV /20170609 CASE 280081 Added support for payload versions in manifest.

    Caption = 'Proxy Assemblies';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Proxy Assembly";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Full Name";"Full Name")
                {
                }
                field(Version;Version)
                {
                }
                field(Imported;Binary.HasValue)
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Import New Assembly")
            {
                Caption = 'Import New Assembly';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ImportWithDialog();
                end;
            }
            action("Export Managed Dependency Manifest")
            {
                Caption = 'Export Managed Dependency Manifest';
                Image = ExportElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ManagedDepMgt: Codeunit "Managed Dependency Mgt.";
                    Rec2: Record "Proxy Assembly";
                    JArray: DotNet JArray;
                begin
                    CurrPage.SetSelectionFilter(Rec2);
                    //-NPR5.32.10 [265454]
                    //ManagedDepMgt.ExportManifest(Rec2);
                    JArray := JArray.JArray();
                    ManagedDepMgt.RecordToJArray(Rec2, JArray);
                    ManagedDepMgt.ExportManifest(Rec2, JArray, 0);
                    //+NPR5.32.10 [265454]
                end;
            }
        }
    }
}

