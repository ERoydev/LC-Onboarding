

export function extractRevertMessageFromError(error: any) {
    let revertMessage;

    if (error?.revert?.args && error?.revert?.args[0]) {
        revertMessage = error.revert.args[0]; // revert reason string
    }
    
    return { error: revertMessage }
}