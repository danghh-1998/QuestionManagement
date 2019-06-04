package set_class;

import java.util.ArrayList;

/**
 * Class khai báo các thuộc tính và phương thức của câu hỏi trắc nghiệm
 * 
 * @author Hoàng Hải Đăng
 *
 */
public class TracNghiem extends CauHoi {
	private ArrayList<DapAnTracNghiem> dsDapAn;

	public TracNghiem(String id, String monHoc, ArrayList<String> chuong, String doKho, String deBai,
			ArrayList<DapAnTracNghiem> dsDapAn) {
		super(id, monHoc, chuong, doKho, deBai);
		this.dsDapAn = dsDapAn;
	}

	public TracNghiem() {

	}

	public ArrayList<DapAnTracNghiem> getDsDapAn() {
		return dsDapAn;
	}

	public void setDsDapAn(ArrayList<DapAnTracNghiem> dsDapAn) {
		this.dsDapAn = dsDapAn;
	}

	@Override
	public String toString() {
		return this.getId();
	}
}
