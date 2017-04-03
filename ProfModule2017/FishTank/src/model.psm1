using namespace System.Collections.Generic
using namespace System.Collection.ObjectModel
using namespace System.Management.Automation


class FishTankModel {
    # unique id
    [string] $ModelName
    # In liters, of course. Standardized since 1901
    [int] $Volume
    # price in €
    [float] $Price
    # height in mm
    [int] $Height
    # Length in mm
    [int] $Length
    # Width in mm
    [int] $Width

    FishTankModel([string] $modelname, [float] $price, [int] $length, [int] $width, [int] $height) {
        $this.ModelName = $modelname
        $this.Volume = $height * $length * $width / 1000000
        $this.Height = $height
        $this.Width = $width
        $this.Length = $length
        $this.Price = $price
    }

    [string] ToString() {
        return '{0} {1:0}x{2:0}x{3:0} cm - {4} liter' -f $this.ModelName, ($this.Length / 10), ($this.Width / 10), ($this.Height / 10), $this.Volume
    }

    static [FishTankModel[]] GetAll() {
        return @(
            [FishTankModel]::new("Aquarium Evolution 40", 78.5, 400, 230, 340)
            [FishTankModel]::new("Aquarium Evolution 50", 118.5, 500, 300, 460)
            [FishTankModel]::new("Aquarium Evolution 60", 138.5, 600, 300, 460)
            [FishTankModel]::new("Aquapro 180", 239, 1000, 400, 450)
            [FishTankModel]::new("Aquastar 96", 144.9, 800, 400, 300)
        )
    }
}


class Fish {
    [string] $Name
    [DateTime] $Aquired

    Fish([string] $name, [datetime] $aquired) {
        $this.Name = $name
        $this.Aquired = $aquired
    }

}

class FishTank {
    [int] $Id
    [FishTankModel] $Model
    [Fish[]] $Fish


    [void] Clean([cmdlet] $cmdlet ) {
        Start-Sleep -Seconds 7
    }

    FishTank([int] $number, [string] $modelName, [int] $volume) {
        $this.ModelNumber = $number
        $this.ModuleName = $modelName
        $this.Volume = $volume
    }
}
