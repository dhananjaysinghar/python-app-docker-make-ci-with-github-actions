import streamlit as st

import pandas as pd

if __name__ == "__main__":
    indexes = [1, 2, 3]
    columns = ['Names', 'Ages', 'Cities']
    names = ['Dhananajay', 'Ramesh', 'Laxmi']
    ages = [21, 25, 27]
    cities = ['Bangalore', 'Bhubaneswar', 'Mumbai']
    data = zip(names, ages, cities)
    df = pd.DataFrame(data=data, index=indexes, columns=columns, )
    st.write(df)
