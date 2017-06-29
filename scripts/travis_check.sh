cd tmp
for file in $(ls)
  do
  cd $file
  R=`travis status --no-interactive`
  echo $file $R
  cd ..
done
