-- Cleaning Data in SQL 

select * 
from [Nashvile Housing]

-------------------------------------------------------------------------------------------------------------------------
-- Standardise Data Format

select SaleDateConverted
from [Nashvile Housing]

update [Nashvile Housing]
set SaleDate = cast(saledate as date)

alter table [Nashvile Housing]
add SaleDateConverted Date; 

update [Nashvile Housing]
Set SaleDateConverted = cast(saledate as date)

-------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data 

Select *
From [Nashvile Housing]
-- where PropertyAddress is null
order by ParcelID

-- for update later(paragraph below)
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashvile Housing] a
join [Nashvile Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Nashvile Housing] a
join [Nashvile Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Adress,City State)

Select PropertyAddress
From [Nashvile Housing]
-- where PropertyAddress is null
-- order by ParcelID

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as Address
from [Nashvile Housing]

alter table [Nashvile Housing]
add PropertySplitAdress Nvarchar(255); 

update [Nashvile Housing]
Set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [Nashvile Housing]
add PropertyCityAdress Nvarchar(255); 

update [Nashvile Housing]
Set PropertyCityAdress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) 

Select *
From [Nashvile Housing]

---------------------------------------------------------------------------------------------------------------------
Select OwnerAddress
From [Nashvile Housing]

select PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
From [Nashvile Housing]

alter table [Nashvile Housing]
add OwnerSplitAddress Nvarchar(255); 

update [Nashvile Housing]
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,3)

alter table [Nashvile Housing]
add OwnerSplitCityAddress Nvarchar(255); 

update [Nashvile Housing]
Set OwnerSplitCityAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,2)

alter table [Nashvile Housing]
add OwnerSplitState Nvarchar(255); 

update [Nashvile Housing]
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.') ,1)

Select *
From [Nashvile Housing]

---------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to yes and no in 'sold as vacant; field
select distinct(SoldasVacant), Count(SoldAsVacant) as CountTotal
from [Nashvile Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant --update for below paragraph 
, CASE when SoldAsVacant='Y' then 'Yes' 
		when SoldAsVacant='N' then 'No' 
		else SoldAsVacant
		END 
from [Nashvile Housing]

Update [Nashvile Housing]
SET SoldAsVacant = CASE when SoldAsVacant='Y' then 'Yes' 
		when SoldAsVacant='N' then 'No' 
		else SoldAsVacant
		END 

select SoldAsVacant
from [Nashvile Housing]

----------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With rownumCTE AS(               -- created a CTE to alter the table --  a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement
Select *,
	ROW_NUMBER() over ( 
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) rownum     -- created new colmun to check for rownumer. if rownumber > 1 that is a duplicate . 
from [Nashvile Housing]
-- order by ParcelID
)

SELECT *   --SELECT CHANGED TO DELETE TO DELETE OFF THE ROWNUM>1
from rownumCTE
where rownum > 1
order by PropertyAddress

--- Duplicates removed (>1)

----------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

SELECT *  
from [Nashvile Housing]

alter table [Nashvile Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

alter table [Nashvile Housing]
DROP COLUMN SaleDate