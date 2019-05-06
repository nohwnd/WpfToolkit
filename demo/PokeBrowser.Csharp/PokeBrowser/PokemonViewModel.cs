namespace PokeBrowser
{
    public class PokemonViewModel : ViewModelBase
    {
        private string _name;
        private string _type;
        private int _height;
        private int _weight;
        private string _image = "";

        public string Name
        {
            get => _name;
            set
            {
                _name = value;
                OnPropertyChanged();
            }
        }

        public string Type
        {
            get => _type;
            set
            {
                _type = value;
                OnPropertyChanged();
            }
        }

        public int Height
        {
            get => _height;
            set
            {
                _height = value;
                OnPropertyChanged();
            }
        }

        public int Weight
        {
            get => _weight;
            set
            {
                _weight = value;
                OnPropertyChanged();
            }
        }

        public string Image
        {
            get => _image;
            set
            {
                _image = value;
                OnPropertyChanged();
            }
        }
    }
}
