let main = async({workflow,captions,parameters}) => 
{
    if (parameters.BoardingPassString){
        await workflow.respond ("InputBoardingPass",{BoardingPass: parameters.BoardingPassString})
    }    
    else {
        var result = await popup.input ({title: captions.boardingpass, caption: captions.boardingpass})
        if (result == null){
            return (" ")
        }
        await workflow.respond ("InputBoardingPass",{BoardingPass: result})        
    }
    

}
