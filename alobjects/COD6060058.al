codeunit 6060058 "Item Wksht. Task Queue Mgt."
{
    // NPR5.43/MHA /20180605  CASE 316948 Object created - Register Item Worksheet with Task Queue NAS

    TableNo = "Task Line";

    trigger OnRun()
    var
        TemplateName: Text;
        BatchName: Text;
        Register: Boolean;
    begin
        TemplateName := UpperCase(GetParameterText('TEMPLATE_NAME'));
        BatchName := UpperCase(GetParameterText('BATCH_NAME'));
        Register := GetParameterBool('REGISTER_ITEM_WKSHT');

        Commit;
        if Register then
          RegisterItemWkshtBatch(TemplateName,BatchName);
    end;

    local procedure RegisterItemWkshtBatch(TemplateName: Text;BatchName: Text)
    var
        ItemWkshtLine: Record "Item Worksheet Line";
    begin
        ItemWkshtLine.FilterGroup(2);
        ItemWkshtLine.SetRange("Worksheet Template Name",TemplateName);
        ItemWkshtLine.SetRange("Worksheet Name",BatchName);
        ItemWkshtLine.FilterGroup(0);

        if ItemWkshtLine.IsEmpty then
          exit;

        CODEUNIT.Run(CODEUNIT::"Item Wsht.-Register Batch",ItemWkshtLine);
    end;
}

