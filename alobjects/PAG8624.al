pageextension 70000578 pageextension70000578 extends "Config. Package Fields" 
{
    // NC2.12/MHA /20180502  CASE 308107 Added fields 6151090 "Field Type", 6151095 "Binary BLOB"
    layout
    {
        addafter("Mapping Exists")
        {
            field("Field Type";"Field Type")
            {
            }
            field("Binary BLOB";"Binary BLOB")
            {
            }
        }
    }
}

