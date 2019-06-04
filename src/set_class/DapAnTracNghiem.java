package set_class;

/**
 * Class khai báo các thuộc tính và phương thức của Đáp án trắc nghiệm
 * 
 * @author Hoàng Hải Đăng
 *
 */
public class DapAnTracNghiem {
	private String dapAn;
	private boolean dungSai;

	public DapAnTracNghiem(String dapAn, boolean dungSai) {
		super();
		this.dapAn = dapAn;
		this.dungSai = dungSai;
	}

	public DapAnTracNghiem() {

	}

	public String getDapAn() {
		return dapAn;
	}

	public void setDapAn(String dapAn) {
		this.dapAn = dapAn;
	}

	public boolean isDungSai() {
		return dungSai;
	}

	public void setDungSai(boolean dungSai) {
		this.dungSai = dungSai;
	}

}
