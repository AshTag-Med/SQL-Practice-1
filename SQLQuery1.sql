Select *
From Proj2.dbo.Sheet1$

--Date Formatting
Select ConvertedSaleDate
From Proj2.dbo.Sheet1$

Alter table Sheet1$
Add ConvertedSaleDate Date;

Update Sheet1$
Set ConvertedSaleDate = CONVERT(Date,SaleDate)

--Replacing Property Address Null with Similar value by UniqueID
Select *
From Proj2.dbo.Sheet1$
Where PropertyAddress is null
Order By ParcelID

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Proj2.dbo.Sheet1$ a
Join Proj2.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Proj2.dbo.Sheet1$ a
Join Proj2.dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Property Address Splitting

Select PropertyAddress
From Proj2.dbo.Sheet1$

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Proj2.dbo.Sheet1$

Alter table Sheet1$
Add PropertyFixedAddress Nvarchar(255);

Update Sheet1$
Set PropertyFixedAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter table Sheet1$
Add PropertyFixedCity Nvarchar(255);

Update Sheet1$
Set PropertyFixedCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

---Owner Address Splitting

Select *
From Proj2.dbo.Sheet1$

Select
PARSENAME( Replace(OwnerAddress, ',', '.') ,3) as Address
,PARSENAME( Replace(OwnerAddress, ',', '.') ,2) as City
,PARSENAME( Replace(OwnerAddress, ',', '.') ,1) as State
From Proj2.dbo.Sheet1$

Alter table Sheet1$
Add OwnerFixedAddress Nvarchar(255);

Alter table Sheet1$
Add OwnerFixedCity Nvarchar(255);

Alter table Sheet1$
Add OwnerFixedState Nvarchar(255);

Update Sheet1$
Set OwnerFixedAddress = PARSENAME( Replace(OwnerAddress, ',', '.') ,3)

Update Sheet1$
Set OwnerFixedCity = PARSENAME( Replace(OwnerAddress, ',', '.') ,2)

Update Sheet1$
Set OwnerFixedState = PARSENAME( Replace(OwnerAddress, ',', '.') ,1)

---Change Value of Sold Column

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END as UpdatedVAC
From Proj2.dbo.Sheet1$

Update Sheet1$
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END


--Testing against standard practice (delete data)

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference,OwnerName
	Order By [UniqueID]) row_num


From Proj2.dbo.Sheet1$
)

--DELETE
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num = 1

Alter Table Sheet1$
Drop Column OwnerAddress, PropertyAddress,SaleDate


--Counting Null OwnerNames
SELECT Count(DISTINCT( ISNULL(OwnerName,'')))
FROM Proj2.dbo.Sheet1$ 
