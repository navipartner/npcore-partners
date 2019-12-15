report 6060040 "Suggest Item Worksheet Lines"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160302  CASE 182391 Fixed error when updating items
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'Suggest Item Worksheet Lines';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Worksheet";"Item Worksheet")
        {
            dataitem(Item;Item)
            {
                RequestFilterFields = "No.";

                trigger OnAfterGetRecord()
                begin
                    LineNo := LineNo + 10000;
                    with ItemWorksheetLine do begin
                      Reset;
                      SetRange("Worksheet Template Name","Item Worksheet"."Item Template Name");
                      SetRange("Worksheet Name","Item Worksheet".Name);
                      SetRange("Existing Item No.",Item."No.");
                      if not FindFirst then begin
                        Init;
                        Validate("Worksheet Template Name","Item Worksheet"."Item Template Name");
                        Validate("Worksheet Name","Item Worksheet".Name);
                        Validate("Line No.",LineNo);
                        Insert(true);
                        //-NPR4.19
                        //VALIDATE(Action,OptDefaultAction);
                        //+NPR4.19
                        Validate("Existing Item No.",Item."No.");
                        //-NPR4.19
                        Validate(Action,OptDefaultAction);
                        if Action = Action::CreateNew then
                          if "Variety Group"  <> '' then
                            Validate("Variety Group")
                          else begin
                            if "Variety 1 Table (Base)" <> '' then
                              Validate("Variety 1 Table (Base)");
                            if "Variety 2 Table (Base)" <> '' then
                              Validate("Variety 2 Table (Base)");
                            if "Variety 3 Table (Base)" <> '' then
                              Validate("Variety 3 Table (Base)");
                            if "Variety 4 Table (Base)" <> '' then
                              Validate("Variety 4 Table (Base)");

                          end;
                        //+NPR4.19
                        Modify(true);

                        if (OptVariants <> OptVariants :: None) then
                          RefreshVariants(OptVariants,true);
                        //-NPR4.19
                        Commit;
                        //+NPR4.19
                      end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                ItemWorksheetLine.Reset;
                ItemWorksheetLine.SetRange("Worksheet Template Name","Item Template Name");
                ItemWorksheetLine.SetRange("Worksheet Name",Name);
                if  ItemWorksheetLine.FindLast then
                  LineNo := ItemWorksheetLine."Line No."
                else
                  LineNo := 0;
            end;

            trigger OnPreDataItem()
            begin
                if "Item Worksheet".Count > 1 then
                  Error(Text1001);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Variants;OptVariants)
                {
                }
                field(Defaults;OptDefaultAction)
                {
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ItemWorksheetLine: Record "Item Worksheet Line";
        LineNo: Integer;
        Text1001: Label 'Please select only one Item Worksheet.';
        OptVariants: Option "None",Variants,"Varieties Without Variants",All;
        OptDefaultAction: Option Skip,"Create New","Update Only","Update and Create Variants";
}

