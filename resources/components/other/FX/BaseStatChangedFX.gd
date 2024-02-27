extends BaseFX
class_name BaseStatChangedFX

var amount: float

func setAmountChanged(setAmount: float):
	amount = setAmount

func isAmountOffensive() -> bool:
	if amount < 0:
		return true
	else:
		return false

func playFX():
	playSFX()
	playVFX()

func playSFX():
	pass

func playVFX():
	pass
